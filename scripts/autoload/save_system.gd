extends Node
## Versioned JSON persistence with checksum, temporary write, and backup recovery.

const SAVE_SCHEMA := 1
const PROFILE_PATH := "user://profile_v1.json"
const RUN_PATH := "user://run_v1.json"

func save_profile(payload: Dictionary) -> bool:
    return _atomic_write(PROFILE_PATH, payload, &"profile")

func load_profile() -> Dictionary:
    return _load_with_backup(PROFILE_PATH, &"profile")

func save_run(payload: Dictionary) -> bool:
    return _atomic_write(RUN_PATH, payload, &"run")

func load_run() -> Dictionary:
    return _load_with_backup(RUN_PATH, &"run")

func clear_run() -> void:
    if FileAccess.file_exists(RUN_PATH): DirAccess.remove_absolute(RUN_PATH)
    if FileAccess.file_exists(RUN_PATH + ".bak"): DirAccess.remove_absolute(RUN_PATH + ".bak")

func _atomic_write(path: String, payload: Dictionary, slot: StringName) -> bool:
    var payload_json := JSON.stringify(payload)
    var envelope := {"schema_version": SAVE_SCHEMA, "checksum": payload_json.sha256_text(), "payload": payload}
    var temporary := path + ".tmp"
    var file := FileAccess.open(temporary, FileAccess.WRITE)
    if file == null:
        EventBus.save_failed.emit(slot, "temporary file could not be opened")
        return false
    file.store_string(JSON.stringify(envelope, "  "))
    file.flush()
    file.close()
    if not _verify_file(temporary):
        DirAccess.remove_absolute(temporary)
        EventBus.save_failed.emit(slot, "temporary file verification failed")
        return false
    if FileAccess.file_exists(path):
        if FileAccess.file_exists(path + ".bak"): DirAccess.remove_absolute(path + ".bak")
        if DirAccess.rename_absolute(path, path + ".bak") != OK:
            EventBus.save_failed.emit(slot, "backup rotation failed")
            return false
    if DirAccess.rename_absolute(temporary, path) != OK:
        if FileAccess.file_exists(path + ".bak"): DirAccess.rename_absolute(path + ".bak", path)
        EventBus.save_failed.emit(slot, "atomic replacement failed")
        return false
    EventBus.save_succeeded.emit(slot)
    return true

func _load_with_backup(path: String, slot: StringName) -> Dictionary:
    for candidate in [path, path + ".bak"]:
        if not FileAccess.file_exists(candidate): continue
        var envelope := _read_envelope(candidate)
        if not envelope.is_empty(): return (envelope.payload as Dictionary).duplicate(true)
    if FileAccess.file_exists(path): EventBus.save_failed.emit(slot, "save and backup are invalid")
    return {}

func _verify_file(path: String) -> bool:
    return not _read_envelope(path).is_empty()

func _read_envelope(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null: return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary: return {}
    var envelope := parsed as Dictionary
    if int(envelope.get("schema_version", 0)) != SAVE_SCHEMA: return {}
    var payload: Variant = envelope.get("payload", {})
    if not payload is Dictionary: return {}
    if String(envelope.get("checksum", "")) != JSON.stringify(payload).sha256_text(): return {}
    return envelope
