class_name NarrativeCommandResource
extends Resource
## Finite, validated narrative mutation command.

enum Kind { SET_FLAG, ADJUST_RELATIONSHIP, REVEAL_LORE, ADVANCE_QUEST, QUEUE_VISION, UNLOCK_META, GRANT_ITEM, EMIT_MESSAGE }

@export var kind: Kind = Kind.SET_FLAG
@export var target_id: StringName
@export var bool_value: bool = true
@export var amount: int = 0
@export var value_text: String

func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    if String(target_id).is_empty(): errors.append("target_id is required")
    return errors
