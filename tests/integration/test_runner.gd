extends Node
## Fast consolidated CI smoke suite; focused scenes provide deeper failures.

func _ready() -> void:
    var failures := PackedStringArray()
    if not ContentRegistry.is_loaded: failures.append("ContentRegistry: %s" % ContentRegistry.get_errors())
    if ContentRegistry.definition_count() < 50: failures.append("definition count below Act I baseline")
    var plan := {"required": "base.story.act1.nave_missing_names", "optional": ["base.story.act1.ash_clinic"]}
    var first := DungeonGenerator.generate_floor(112358, 2, plan)
    var second := DungeonGenerator.generate_floor(112358, 2, plan)
    if first.is_empty() or JSON.stringify(first) != JSON.stringify(second): failures.append("deterministic dungeon mismatch")
    var player := ActorFactory.create(&"base.entity.player.warden", &"test-player", Vector2i(2, 2))
    var enemy := ActorFactory.create(&"base.enemy.ash_hound", &"test-enemy", Vector2i(3, 2))
    if player == null or enemy == null: failures.append("actor factory failed")
    else:
        add_child(player); add_child(enemy)
        var before := enemy.health.current
        CombatSystem.resolve_attack(player, enemy)
        if enemy.health.current >= before: failures.append("combat did not resolve damage")
    if not DialogueManager.start(&"base.dialogue.hub.maelin"): failures.append("dialogue startup failed")
    else:
        DialogueManager.advance()
        if String(DialogueManager.current_view().get("type", "")) != "choice": failures.append("dialogue branch not reached")
    if not SaveSystem.save_run({"ci_probe": true}) or not bool(SaveSystem.load_run().get("ci_probe", false)): failures.append("save roundtrip failed")
    SaveSystem.clear_run()
    if failures.is_empty():
        print("PASS consolidated Act I runtime suite")
        get_tree().quit(0)
    else:
        for failure in failures: push_error(failure)
        get_tree().quit(1)
