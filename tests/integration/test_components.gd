extends Node

func _ready() -> void:
    var result := _run()
    if result.is_empty():
        print("PASS component composition, combat, status, energy, AI, and FOV")
        get_tree().quit(0)
    else:
        push_error(result)
        get_tree().quit(1)

func _run() -> String:
    var player := ActorFactory.create(&"base.entity.player.warden", &"player", Vector2i(2, 2), 0)
    var hound := ActorFactory.create(&"base.enemy.ash_hound", &"hound-1", Vector2i(3, 2), 1)
    if player == null or hound == null: return "ActorFactory failed"
    add_child(player); add_child(hound)
    var before: int = hound.health.current
    var receipt: Dictionary = CombatSystem.resolve_attack(player, hound)
    if not receipt.get("success", false) or hound.health.current >= before: return "Combat resolution did not damage target"
    if not hound.apply_status(&"base.status.slowed", 2) or hound.statuses.modifier(&"speed") >= 0: return "Status modifier failed"
    player.timeline.force_ready()
    if not player.timeline.is_ready() or not player.timeline.consume(Balance.config.move_energy_cost): return "Energy timeline failed"
    var intent: Dictionary = hound.ai.choose_intent(hound.grid_position, player.grid_position, true)
    if String(intent.get("type", "")) != "attack": return "Chase AI did not attack adjacent target"
    var walls := {Vector2i(4, 2): true}
    var visible: Dictionary = FOVSystem.compute(Vector2i(2, 2), 7, func(point: Vector2i) -> bool: return walls.has(point))
    if not visible.has(Vector2i(4, 2)) or visible.has(Vector2i(5, 2)): return "Shadowcasting wall occlusion failed"
    if FOVSystem.has_line_of_sight(Vector2i(2, 2), Vector2i(6, 2), func(point: Vector2i) -> bool: return walls.has(point)): return "Line of sight crossed an opaque tile"
    return ""
