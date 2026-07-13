extends SceneTree

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    await process_frame
    var registry: Node = root.get_node("ContentRegistry")
    if not registry.is_loaded:
        for error: String in registry.get_errors(): print("CONTENT_ERROR ", error)
        quit(1)
        return
    print("Content validation passed: %d definitions, %d locale keys." % [registry.definition_count(), (JSON.parse_string(FileAccess.get_file_as_string("res://content/base/localization/en.json")) as Dictionary).entries.size()])
    quit(0)
