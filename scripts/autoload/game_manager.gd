extends Node
## Application/run lifecycle, floor transitions, death transaction, and scene mode.

enum Mode { BOOT, SANCTUM, RUN, DIALOGUE, GAME_OVER }
var mode := Mode.BOOT
var run_id := ""
var run_seed := 0
var floor_index := 0
var defeated_count := 0
var current_manifest: Dictionary = {}

func _ready() -> void:
    call_deferred("enter_sanctum")

func enter_sanctum() -> void:
    mode = Mode.SANCTUM
    floor_index = 0
    current_manifest.clear()
    EventBus.hub_entered.emit(MetaProgressionSystem.snapshot())

func start_new_run(seed_override := 0) -> Dictionary:
    run_seed = seed_override if seed_override != 0 else int(Time.get_unix_time_from_system()) ^ MetaProgressionSystem.death_count * 7919
    run_id = "%s-%s" % [Time.get_unix_time_from_system(), abs(run_seed)]
    floor_index = 1
    defeated_count = 0
    mode = Mode.RUN
    InventorySystem.reset_for_run()
    QuestSystem.active.clear()
    CombatSystem.begin_run(run_seed)
    QuestSystem.start_quest(&"base.quest.act1.a_name_returned")
    EventBus.run_started.emit(run_id, run_seed)
    return request_floor()

func request_floor() -> Dictionary:
    var story_plan := NarrativeSystem.build_floor_plan(floor_index)
    current_manifest = DungeonGenerator.generate_floor(run_seed, floor_index, story_plan)
    EventBus.floor_generated.emit(floor_index, current_manifest)
    SaveSystem.save_run(snapshot())
    return current_manifest

func descend() -> Dictionary:
    floor_index += 1
    if floor_index > 3: floor_index = 3
    return request_floor()

func register_defeat() -> void:
    defeated_count += 1

func resolve_player_death(cause := "unknown") -> Dictionary:
    var summary := {"run_id": run_id, "seed": run_seed, "floor": floor_index, "defeated": defeated_count, "lore": LoreSystem.discovered.size(), "cause": cause, "caedmon_restored": bool(NarrativeSystem.flags.get("base.flag.caedmon_chose_after_restoration", false))}
    var essence := MetaProgressionSystem.resolve_run(summary)
    summary["essence"] = essence
    SaveSystem.clear_run()
    EventBus.permadeath_resolved.emit(summary)
    enter_sanctum()
    return summary

func snapshot() -> Dictionary:
    return {"run_id": run_id, "seed": run_seed, "floor": floor_index, "defeated": defeated_count, "manifest": current_manifest.duplicate(true), "inventory": InventorySystem.snapshot(), "quests": QuestSystem.snapshot(), "lore": LoreSystem.snapshot(), "narrative": NarrativeSystem.snapshot()}
