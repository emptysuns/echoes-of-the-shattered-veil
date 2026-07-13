extends Node
## Thin gameplay orchestrator joining services, actors, world view, and UI.

@onready var world: DungeonView = $DungeonView
@onready var camera: Camera2D = $DungeonView/Camera2D
@onready var ui: GameUI = $GameUI

var manifest: Dictionary = {}
var player: Actor
var enemy_sequence := 100
var explored: Dictionary = {}
var _transitioning := false
var _caedmon_dialogue_started := false
var _resolved_story_positions: Dictionary = {}

func _ready() -> void:
    ui.start_run_requested.connect(_start_run)
    ui.direction_requested.connect(_try_player_move)
    ui.wait_requested.connect(_wait_turn)
    ui.npc_requested.connect(func(dialogue_id: StringName) -> void: DialogueManager.start(dialogue_id))
    ui.dialogue_advance_requested.connect(DialogueManager.advance)
    ui.dialogue_choice_requested.connect(DialogueManager.choose)
    ui.language_toggle_requested.connect(_toggle_language)
    EventBus.dialogue_updated.connect(ui.show_dialogue)
    EventBus.dialogue_ended.connect(_on_dialogue_ended)
    EventBus.message_enqueued.connect(_on_message_enqueued)
    EventBus.damage_resolved.connect(_on_damage_resolved)
    EventBus.lore_discovered.connect(func(_id: StringName) -> void: _refresh_ui())
    GameManager.enter_sanctum()
    ui.show_hub()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause_game"):
        get_tree().paused = not get_tree().paused
        return
    if DialogueManager.active:
        if event.is_action_pressed("confirm_action"): DialogueManager.advance()
        return
    if event.is_action_pressed("cancel_action"):
        ui.close_overlay()
        return
    if GameManager.mode == GameManager.Mode.SANCTUM:
        if event.is_action_pressed("confirm_action"): _start_run()
        return
    if GameManager.mode != GameManager.Mode.RUN or UIManager.has_modal(): return
    var direction := Vector2i.ZERO
    if event.is_action_pressed("move_north"): direction = Vector2i.UP
    elif event.is_action_pressed("move_north_east"): direction = Vector2i(1, -1)
    elif event.is_action_pressed("move_east"): direction = Vector2i.RIGHT
    elif event.is_action_pressed("move_south_east"): direction = Vector2i(1, 1)
    elif event.is_action_pressed("move_south"): direction = Vector2i.DOWN
    elif event.is_action_pressed("move_south_west"): direction = Vector2i(-1, 1)
    elif event.is_action_pressed("move_west"): direction = Vector2i.LEFT
    elif event.is_action_pressed("move_north_west"): direction = Vector2i(-1, -1)
    if direction != Vector2i.ZERO: _try_player_move(direction)
    elif event.is_action_pressed("wait_turn"): _wait_turn()
    elif event.is_action_pressed("open_inventory"): ui.show_inventory()
    elif event.is_action_pressed("open_codex"): ui.show_codex()
    elif event.is_action_pressed("open_message_history"): ui.show_messages()
    elif event.is_action_pressed("quick_slot_1"): _use_tonic()

func _start_run() -> void:
    if _transitioning: return
    _transitioning = false
    _caedmon_dialogue_started = false
    var floor_manifest := GameManager.start_new_run()
    _load_floor(floor_manifest)
    ui.show_hud()
    ui.append_message(ContentRegistry.text(&"biome.ashen_narthex.description"))

func _load_floor(floor_manifest: Dictionary) -> void:
    manifest = floor_manifest
    explored.clear(); _resolved_story_positions.clear(); _caedmon_dialogue_started = false
    world.load_floor(manifest)
    var raw_start: Array = manifest.start
    player = ActorFactory.create(&"base.entity.player.warden", &"player", Vector2i(int(raw_start[0]), int(raw_start[1])), 0)
    world.add_actor(player)
    player.died.connect(_on_actor_died)
    player.timeline.force_ready()
    for actor_data: Dictionary in manifest.actors:
        var raw: Array = actor_data.position
        var actor := ActorFactory.create(StringName(actor_data.definition_id), StringName(actor_data.actor_id), Vector2i(int(raw[0]), int(raw[1])), int(actor_data.sequence))
        if actor != null:
            if bool(actor_data.get("elite", false)): actor.make_elite()
            world.add_actor(actor)
            actor.died.connect(_on_actor_died)
    _update_fov()
    _refresh_ui()
    EventBus.message_enqueued.emit(&"narrative", &"message.stairs", {})

func _try_player_move(direction: Vector2i) -> void:
    if not _can_player_act(): return
    var target_position := player.grid_position + direction
    var target := world.actor_at(target_position, player)
    var committed := false
    if target != null:
        if target.definition.faction == &"hostile":
            CombatSystem.resolve_attack(player, target)
            committed = true
            if target.is_alive() and target.actor_id == &"caedmon" and target.health.ratio() <= 0.60 and not _caedmon_dialogue_started:
                _caedmon_dialogue_started = true
                QuestSystem.advance(&"base.quest.act1.a_name_returned", &"confronted_caedmon")
                DialogueManager.start(&"base.dialogue.boss.caedmon")
    elif DungeonGenerator.is_walkable(manifest, target_position):
        player.set_grid_position(target_position)
        committed = true
        _resolve_current_tile()
    if committed and is_instance_valid(player) and player.is_alive(): _finish_player_action()

func _wait_turn() -> void:
    if not _can_player_act(): return
    EventBus.action_committed.emit({"actor": player.actor_id, "type": "wait"})
    _finish_player_action()

func _finish_player_action() -> void:
    player.timeline.consume(Balance.config.move_energy_cost)
    player.statuses.tick(StatusEffectResource.TickTiming.AFTER_ACTION, player)
    _run_enemy_turns()
    if is_instance_valid(player) and player.is_alive():
        player.timeline.force_ready()
        _update_fov(); _refresh_ui()
        SaveSystem.save_run(GameManager.snapshot())

func _run_enemy_turns() -> void:
    var enemies: Array[Actor] = []
    for actor: Actor in world.actors.values():
        if actor != player and actor.is_alive(): enemies.append(actor)
    enemies.sort_custom(func(a: Actor, b: Actor) -> bool: return a.spawn_sequence < b.spawn_sequence)
    for enemy in enemies:
        if not is_instance_valid(enemy) or not enemy.is_alive() or not player.is_alive(): continue
        enemy.timeline.force_ready()
        var can_see := FOVSystem.has_line_of_sight(enemy.grid_position, player.grid_position, func(point: Vector2i) -> bool: return DungeonGenerator.is_opaque(manifest, point))
        var intent := enemy.ai.choose_intent(enemy.grid_position, player.grid_position, can_see, enemy.health.ratio())
        match String(intent.get("type", "wait")):
            "attack": CombatSystem.resolve_attack(enemy, player, int(intent.get("power", 0)))
            "ranged": CombatSystem.resolve_attack(enemy, player, int(intent.get("power", 0)), true)
            "move":
                var direction: Vector2i = intent.get("direction", Vector2i.ZERO)
                var next: Vector2i = enemy.grid_position + direction
                if DungeonGenerator.is_walkable(manifest, next) and world.actor_at(next, enemy) == null: enemy.set_grid_position(next)
            "summon": _summon_near(enemy, StringName(intent.get("entity_id", &"base.enemy.ash_hound")))
        enemy.timeline.consume(Balance.config.move_energy_cost)
        enemy.statuses.tick(StatusEffectResource.TickTiming.AFTER_ACTION, enemy)

func _summon_near(summoner: Actor, entity_id: StringName) -> void:
    for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
        var point: Vector2i = summoner.grid_position + direction
        if DungeonGenerator.is_walkable(manifest, point) and world.actor_at(point) == null:
            enemy_sequence += 1
            var actor := ActorFactory.create(entity_id, StringName("summon-%d" % enemy_sequence), point, enemy_sequence)
            if actor != null:
                world.add_actor(actor); actor.died.connect(_on_actor_died)
            return

func _resolve_current_tile() -> void:
    var tile := DungeonGenerator.tile_at(manifest, player.grid_position)
    if tile == BSPGenerator.Tile.TRAP:
        player.take_damage(3)
        _replace_tile(player.grid_position, BSPGenerator.Tile.FLOOR)
        EventBus.message_enqueued.emit(&"combat", &"message.trap", {})
    for index in range((manifest.items as Array).size() - 1, -1, -1):
        var item: Dictionary = manifest.items[index]
        if _point(item.position) == player.grid_position:
            InventorySystem.add_item(String(item.item_id))
            if String(item.item_id) == "base.item.quest.lysa_paper_bird":
                NarrativeSystem.set_flag("base.flag.lysa_bird_found", true)
                _advance_quest_evidence(&"found_bird")
            manifest.items.remove_at(index)
    for placement: Dictionary in manifest.story_beats:
        if _point(placement.position) == player.grid_position and not _resolved_story_positions.has(String(placement.beat_id)):
            _resolved_story_positions[String(placement.beat_id)] = true
            NarrativeSystem.trigger_beat(StringName(placement.beat_id))
            var lore_id := _lore_for_beat(String(placement.beat_id))
            if not String(lore_id).is_empty():
                LoreSystem.discover(lore_id)
                if lore_id == &"base.lore.act1.caedmon_order": _advance_quest_evidence(&"found_order")
            EventBus.message_enqueued.emit(&"narrative", &"message.story_room", {})
    var raw_exit: Array = manifest.exit
    if player.grid_position == Vector2i(int(raw_exit[0]), int(raw_exit[1])) and not _has_living_boss():
        if GameManager.floor_index < 3:
            _load_floor(GameManager.descend())
        else:
            _complete_act()

func _advance_quest_evidence(step: StringName) -> void:
    var current := QuestSystem.current_step(&"base.quest.act1.a_name_returned")
    if current == &"": QuestSystem.start_quest(&"base.quest.act1.a_name_returned")
    QuestSystem.advance(&"base.quest.act1.a_name_returned", step)

func _lore_for_beat(beat_id: String) -> StringName:
    match beat_id:
        "base.story.act1.nave_missing_names": return &"base.lore.act1.caedmon_order"
        "base.story.act1.ash_clinic": return &"base.lore.act1.burnt_triage_slate"
        "base.story.act1.bellmakers_cell": return &"base.lore.act1.lysa_paper_bird"
    return &""

func _on_actor_died(actor: Actor, _source: Node) -> void:
    if actor == player:
        _resolve_death.call_deferred()
        return
    var was_boss := actor.actor_id == &"caedmon"
    world.remove_actor(actor)
    GameManager.register_defeat()
    if was_boss:
        if not _has_caedmon_resolution(): NarrativeSystem.set_flag("base.flag.caedmon_extracted", true)
        _resolve_caedmon_quest()
        _complete_act()

func _on_dialogue_ended(dialogue_id: StringName) -> void:
    ui.hide_dialogue()
    if dialogue_id == &"base.dialogue.boss.caedmon" and _has_caedmon_resolution():
        var boss := world.actors.get("caedmon") as Actor
        if boss != null: world.remove_actor(boss)
        _resolve_caedmon_quest()
        _complete_act()

func _resolve_caedmon_quest() -> void:
    if bool(NarrativeSystem.flags.get("base.flag.caedmon_chose_after_restoration", false)):
        QuestSystem.advance(&"base.quest.act1.a_name_returned", &"restored")
    elif bool(NarrativeSystem.flags.get("base.flag.caedmon_protocol_suspended", false)):
        QuestSystem.advance(&"base.quest.act1.a_name_returned", &"suspended")
    else:
        QuestSystem.advance(&"base.quest.act1.a_name_returned", &"extracted")

func _has_caedmon_resolution() -> bool:
    return bool(NarrativeSystem.flags.get("base.flag.caedmon_chose_after_restoration", false)) or bool(NarrativeSystem.flags.get("base.flag.caedmon_protocol_suspended", false)) or bool(NarrativeSystem.flags.get("base.flag.caedmon_extracted", false))

func _has_living_boss() -> bool:
    var boss := world.actors.get("caedmon") as Actor
    return boss != null and boss.is_alive()

func _complete_act() -> void:
    if _transitioning: return
    _transitioning = true
    SaveSystem.clear_run()
    ui.show_banner(ContentRegistry.text(&"ui.victory"))
    await get_tree().create_timer(2.0).timeout
    GameManager.enter_sanctum(); ui.show_hub(); _transitioning = false

func _resolve_death() -> void:
    if _transitioning: return
    _transitioning = true
    var summary := GameManager.resolve_player_death("combat")
    ui.show_banner("%s\n+%d %s" % [ContentRegistry.text(&"ui.death"), summary.essence, ContentRegistry.text(&"ui.essence")])
    await get_tree().create_timer(2.0).timeout
    world.clear_actors(); ui.show_hub(); _transitioning = false

func _use_tonic() -> void:
    if player != null and InventorySystem.use_consumable("base.item.consumable.echo_tonic", player):
        ui.append_message(ContentRegistry.text(&"base.item.consumable.echo_tonic.description")); _refresh_ui()

func _update_fov() -> void:
    if player == null or manifest.is_empty(): return
    var radius := player.definition.stats.vision_range
    var visible := FOVSystem.compute(player.grid_position, radius, func(point: Vector2i) -> bool: return DungeonGenerator.is_opaque(manifest, point))
    for point: Vector2i in visible.keys(): explored[point] = true
    world.set_visibility(visible, explored)
    camera.position = Vector2(player.grid_position * 32) + Vector2(16, 16)
    ui.minimap.set_data(manifest, explored, player.grid_position)

func _refresh_ui() -> void:
    if player != null: ui.update_hud(player, GameManager.floor_index)

func _replace_tile(point: Vector2i, tile: int) -> void:
    var tiles: Array = manifest.tiles
    tiles[point.y * int(manifest.width) + point.x] = tile
    manifest.tiles = tiles; world.queue_redraw()

func _toggle_language() -> void:
    ContentRegistry.set_locale("en" if ContentRegistry.get_locale() == "zh_CN" else "zh_CN")
    ui.refresh_locale()

func _on_message_enqueued(_channel: StringName, text_key: StringName, _parameters: Dictionary) -> void:
    ui.append_message(ContentRegistry.text(text_key))

func _on_damage_resolved(receipt: Dictionary) -> void:
    var key := &"message.enemy_hit" if String(receipt.attacker) == "player" else &"message.player_hit"
    ui.append_message("%s (%d)" % [ContentRegistry.text(key), int(receipt.damage)])
    _refresh_ui()

func _can_player_act() -> bool:
    return GameManager.mode == GameManager.Mode.RUN and player != null and player.is_alive() and player.timeline.is_ready() and not UIManager.has_modal() and not _transitioning

func _point(raw: Array) -> Vector2i:
    return Vector2i(int(raw[0]), int(raw[1]))
