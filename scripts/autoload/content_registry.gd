extends Node
## Loads .tres and JSON content into one validated, read-only lookup surface.

signal content_loaded(definition_count: int)
signal content_validation_failed(errors: PackedStringArray)
signal locale_changed(locale: String)

const BASE_CONTENT_PATH := "res://content/base"
const RESOURCE_PATH := "res://resources"
const SUPPORTED_LOCALES := ["zh_CN", "en"]

var _definitions: Dictionary = {}
var _dialogues: Dictionary = {}
var _localizations: Dictionary = {}
var _errors := PackedStringArray()
var _current_locale := "zh_CN"
var is_loaded := false

func _ready() -> void:
    load_all()

func load_all() -> bool:
    _definitions.clear()
    _dialogues.clear()
    _localizations.clear()
    _errors.clear()
    _load_resource_directory(RESOURCE_PATH)
    for locale in SUPPORTED_LOCALES:
        _load_locale(locale)
    _load_json_directory(BASE_CONTENT_PATH + "/dialogues", _dialogues, "dialogue_id")
    _validate_locale_parity()
    is_loaded = _errors.is_empty()
    if is_loaded:
        content_loaded.emit(_definitions.size())
    else:
        content_validation_failed.emit(_errors.duplicate())
    return is_loaded

func get_definition(content_id: StringName) -> ContentDefinition:
    return _definitions.get(content_id) as ContentDefinition

func has_definition(content_id: StringName) -> bool:
    return _definitions.has(content_id)

func definitions_by_tag(tag: String) -> Array[ContentDefinition]:
    var result: Array[ContentDefinition] = []
    for definition: ContentDefinition in _definitions.values():
        if tag in definition.tags:
            result.append(definition)
    result.sort_custom(func(a: ContentDefinition, b: ContentDefinition) -> bool: return String(a.content_id) < String(b.content_id))
    return result

func definitions_of_type(type_script: Script) -> Array[ContentDefinition]:
    var result: Array[ContentDefinition] = []
    for definition: ContentDefinition in _definitions.values():
        if is_instance_of(definition, type_script):
            result.append(definition)
    return result

func get_dialogue(dialogue_id: StringName) -> Dictionary:
    return (_dialogues.get(String(dialogue_id), {}) as Dictionary).duplicate(true)

func set_locale(locale: String) -> bool:
    if locale not in SUPPORTED_LOCALES:
        return false
    _current_locale = locale
    locale_changed.emit(locale)
    return true

func get_locale() -> String:
    return _current_locale

func text(key: StringName, locale_override := "") -> String:
    var locale := locale_override if not locale_override.is_empty() else _current_locale
    var catalog: Dictionary = _localizations.get(locale, {})
    var string_key := String(key)
    if catalog.has(string_key):
        return String(catalog[string_key])
    var fallback: Dictionary = _localizations.get("en", {})
    if fallback.has(string_key):
        return String(fallback[string_key])
    return "[%s]" % string_key

func get_errors() -> PackedStringArray:
    return _errors.duplicate()

func definition_count() -> int:
    return _definitions.size()

func _load_resource_directory(path: String) -> void:
    var directory := DirAccess.open(path)
    if directory == null:
        _errors.append("Cannot open resource directory: %s" % path)
        return
    directory.list_dir_begin()
    var entry := directory.get_next()
    while not entry.is_empty():
        if entry != "." and entry != "..":
            var full_path := path.path_join(entry)
            if directory.current_is_dir():
                _load_resource_directory(full_path)
            elif entry.ends_with(".tres"):
                _register_resource(full_path)
        entry = directory.get_next()
    directory.list_dir_end()

func _register_resource(path: String) -> void:
    var resource := ResourceLoader.load(path)
    if resource == null:
        _errors.append("Failed to load resource: %s" % path)
        return
    if not resource is ContentDefinition:
        return
    var definition := resource as ContentDefinition
    var validation_errors := definition.validate()
    for error in validation_errors:
        _errors.append("%s: %s" % [path, error])
    if not validation_errors.is_empty():
        return
    if _definitions.has(definition.content_id):
        _errors.append("Duplicate content ID %s at %s" % [definition.content_id, path])
        return
    _definitions[definition.content_id] = definition

func _load_locale(locale: String) -> void:
    var path := "%s/localization/%s.json" % [BASE_CONTENT_PATH, locale]
    var data := _read_json(path)
    if data.is_empty():
        return
    if String(data.get("locale", "")) != locale:
        _errors.append("Locale mismatch in %s" % path)
        return
    _localizations[locale] = (data.get("entries", {}) as Dictionary).duplicate(true)

func _load_json_directory(path: String, target: Dictionary, id_key: String) -> void:
    var directory := DirAccess.open(path)
    if directory == null:
        _errors.append("Cannot open JSON directory: %s" % path)
        return
    for file_name in directory.get_files():
        if not file_name.ends_with(".json"):
            continue
        var data := _read_json(path.path_join(file_name))
        var content_id := String(data.get(id_key, ""))
        if content_id.is_empty():
            _errors.append("%s has no %s" % [file_name, id_key])
        elif target.has(content_id):
            _errors.append("Duplicate JSON content ID: %s" % content_id)
        else:
            target[content_id] = data

func _read_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        _errors.append("Cannot read JSON: %s" % path)
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        _errors.append("Invalid JSON object: %s" % path)
        return {}
    return parsed as Dictionary

func _validate_locale_parity() -> void:
    if not _localizations.has("zh_CN") or not _localizations.has("en"):
        _errors.append("Both zh_CN and en catalogs are required")
        return
    var zh_keys := (_localizations["zh_CN"] as Dictionary).keys()
    var en_keys := (_localizations["en"] as Dictionary).keys()
    for key in zh_keys:
        if key not in en_keys: _errors.append("Missing English key: %s" % key)
    for key in en_keys:
        if key not in zh_keys: _errors.append("Missing Chinese key: %s" % key)
