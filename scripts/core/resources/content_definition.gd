class_name ContentDefinition
extends Resource
## Base class for immutable, namespaced authored content.

@export var content_id: StringName
@export var display_name_key: StringName
@export var description_key: StringName
@export var tags: PackedStringArray = []

func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    var id_text := String(content_id)
    if id_text.is_empty():
        errors.append("content_id is required")
    elif not id_text.is_valid_identifier() and "." not in id_text:
        errors.append("content_id must be namespaced")
    elif id_text.to_lower() != id_text or " " in id_text:
        errors.append("content_id must be lowercase and contain no spaces")
    if String(display_name_key).is_empty():
        errors.append("display_name_key is required")
    return errors
