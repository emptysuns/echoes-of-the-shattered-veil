extends Node

const MAIN_SCENE := preload("res://scenes/bootstrap/main.tscn")

func _ready() -> void:
    _run.call_deferred()

func _run() -> void:
    var main := MAIN_SCENE.instantiate()
    add_child(main)
    await get_tree().process_frame
    main._start_run()
    await get_tree().process_frame
    if GameManager.mode != GameManager.Mode.RUN or main.manifest.is_empty() or main.player == null:
        _fail("main scene did not start a playable run"); return
    if (main.manifest.story_beats as Array).is_empty() or (main.world.actors as Dictionary).size() < 2:
        _fail("playable floor lacks narrative or actors"); return
    var moved := false
    var before: Vector2i = main.player.grid_position
    for direction: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
        var target := before + direction
        if DungeonGenerator.is_walkable(main.manifest, target) and main.world.actor_at(target, main.player) == null:
            main._try_player_move(direction)
            moved = main.player.grid_position != before
            break
    if not moved:
        _fail("semantic movement did not move player to an adjacent floor tile"); return
    main.ui.show_inventory(); main.ui.close_overlay(); main.ui.show_codex(); main.ui.close_overlay()
    if not main.player.timeline.is_ready():
        _fail("player was not returned to a ready discrete turn"); return
    print("PASS main scene starts run, moves, resolves enemy turns, and opens overlays")
    get_tree().quit(0)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
