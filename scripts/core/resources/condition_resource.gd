class_name ConditionResource
extends Resource
## Declarative condition tree; arbitrary expressions are deliberately unsupported.

enum Kind { ALWAYS, ALL, ANY, NOT, FLAG_EQUALS, RELATIONSHIP_AT_LEAST, LORE_RATIO_AT_LEAST, META_AT_LEAST, NPC_ALIVE }

@export var kind: Kind = Kind.ALWAYS
@export var children: Array[ConditionResource] = []
@export var target_id: StringName
@export var expected_bool: bool = true
@export var threshold: float = 0.0

func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    if kind in [Kind.ALL, Kind.ANY] and children.is_empty(): errors.append("composite condition requires children")
    if kind == Kind.NOT and children.size() != 1: errors.append("NOT requires exactly one child")
    if kind in [Kind.FLAG_EQUALS, Kind.RELATIONSHIP_AT_LEAST, Kind.NPC_ALIVE] and String(target_id).is_empty():
        errors.append("target_id is required")
    return errors
