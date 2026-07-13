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
    _validate_dialogue_graphs()
    _validate_definition_references()
    _validate_definition_localization()
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


func _validate_dialogue_graphs() -> void:
    for dialogue_id: String in _dialogues:
        var graph := _dialogues[dialogue_id] as Dictionary
        var nodes := graph.get("nodes", {}) as Dictionary
        var start := String(graph.get("start_node", ""))
        if not nodes.has(start): _errors.append("Dialogue %s has unknown start node %s" % [dialogue_id, start])
        for node_id: String in nodes:
            var node := nodes[node_id] as Dictionary
            var node_type := String(node.get("type", ""))
            if node_type == "line":
                _require_translation(String(node.get("text_key", "")), "Dialogue %s node %s" % [dialogue_id, node_id])
                var next := String(node.get("next", ""))
                if not nodes.has(next): _errors.append("Dialogue %s node %s points to unknown %s" % [dialogue_id, node_id, next])
            elif node_type == "choice":
                var choices: Array = node.get("choices", [])
                if choices.is_empty(): _errors.append("Dialogue %s choice node %s is empty" % [dialogue_id, node_id])
                for choice: Dictionary in choices:
                    _require_translation(String(choice.get("text_key", "")), "Dialogue %s choice %s" % [dialogue_id, node_id])
                    var next := String(choice.get("next", ""))
                    if not nodes.has(next): _errors.append("Dialogue %s choice %s points to unknown %s" % [dialogue_id, node_id, next])
            elif node_type != "end":
                _errors.append("Dialogue %s node %s has unsupported type %s" % [dialogue_id, node_id, node_type])

func _validate_definition_references() -> void:
    for definition: ContentDefinition in _definitions.values():
        if definition is ItemDefinitionResource:
            for effect_id in (definition as ItemDefinitionResource).effect_ids: _require_definition(effect_id, definition.content_id)
        elif definition is BiomeDefinitionResource:
            var biome := definition as BiomeDefinitionResource
            for target_id in biome.spawn_entity_ids: _require_definition(target_id, definition.content_id)
            for target_id in biome.item_ids: _require_definition(target_id, definition.content_id)
            for target_id in biome.story_event_ids: _require_definition(target_id, definition.content_id)
        elif definition is StoryEventResource:
            var story := definition as StoryEventResource
            if not String(story.fallback_room_id).is_empty(): _require_definition(story.fallback_room_id, definition.content_id)
        elif definition is EffectDefinitionResource:
            var effect := definition as EffectDefinitionResource
            if not String(effect.target_id).is_empty(): _require_definition(effect.target_id, definition.content_id)
        elif definition is NPCDefinitionResource:
            for dialogue_id in (definition as NPCDefinitionResource).dialogue_ids:
                if not _dialogues.has(String(dialogue_id)): _errors.append("%s references missing dialogue %s" % [definition.content_id, dialogue_id])
        elif definition is EndingResource:
            for npc_id in (definition as EndingResource).required_survivors: _require_definition(npc_id, definition.content_id)

func _validate_definition_localization() -> void:
    for definition: ContentDefinition in _definitions.values():
        _require_translation(String(definition.display_name_key), String(definition.content_id))
        if not String(definition.description_key).is_empty(): _require_translation(String(definition.description_key), String(definition.content_id))
        if definition is LoreEntryResource: _require_translation(String((definition as LoreEntryResource).body_key), String(definition.content_id))
        elif definition is MemoryVisionResource:
            for frame_key in (definition as MemoryVisionResource).frame_text_keys: _require_translation(frame_key, String(definition.content_id))

func _require_definition(target_id: StringName, source_id: StringName) -> void:
    if not _definitions.has(target_id): _errors.append("%s references missing definition %s" % [source_id, target_id])

func _require_translation(key: String, source: String) -> void:
    if key.is_empty():
        _errors.append("%s has an empty localization key" % source)
        return
    for locale in SUPPORTED_LOCALES:
        if not (_localizations.get(locale, {}) as Dictionary).has(key): _errors.append("%s missing %s translation %s" % [source, locale, key])
