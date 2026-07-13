extends Node

const MAIN_SCENE := preload("res://scenes/bootstrap/main.tscn")

func _ready() -> void:
    _run.call_deferred()

func _run() -> void:
    var main := MAIN_SCENE.instantiate()
    add_child(main)
    await get_tree().process_frame
    await get_tree().process_frame
    if GameManager.mode != GameManager.Mode.SANCTUM:
        _fail("expected Sanctum before Start click")
        return
    if ContentRegistry.get_locale() != "en":
        _fail("English must be the default game locale")
        return
    var start_button: Button = main.ui.hub_start_button
    if start_button.text != ContentRegistry.text(&"ui.start_run", "en"):
        _fail("Start button did not render in the default English locale")
        return
    var center := start_button.get_global_rect().get_center()
    var motion := InputEventMouseMotion.new()
    motion.position = center
    motion.global_position = center
    Input.parse_input_event(motion)
    var down := InputEventMouseButton.new()
    down.button_index = MOUSE_BUTTON_LEFT
    down.position = center
    down.global_position = center
    down.pressed = true
    Input.parse_input_event(down)
    var up := InputEventMouseButton.new()
    up.button_index = MOUSE_BUTTON_LEFT
    up.position = center
    up.global_position = center
    up.pressed = false
    Input.parse_input_event(up)
    await get_tree().process_frame
    await get_tree().process_frame
    if GameManager.mode != GameManager.Mode.RUN:
        var hovered := get_viewport().gui_get_hovered_control()
        _fail("Start click was intercepted; hovered=%s" % (hovered.name if hovered != null else "none"))
        return
    print("PASS start screen accepts mouse click")
    get_tree().quit(0)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
