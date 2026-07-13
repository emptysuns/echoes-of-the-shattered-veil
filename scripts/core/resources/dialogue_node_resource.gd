class_name DialogueNodeResource
extends Resource
## One node in a directed dialogue graph.

enum Kind { LINE, CHOICE, GATE, COMMAND, JUMP, END }

@export var node_id: StringName
@export var kind: Kind = Kind.LINE
@export var speaker_id: StringName
@export var text_key: StringName
@export var next_node_id: StringName
@export var choice_text_keys: PackedStringArray = []
@export var choice_next_node_ids: PackedStringArray = []
@export var condition: ConditionResource
@export var commands: Array[NarrativeCommandResource] = []

func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    if String(node_id).is_empty(): errors.append("node_id is required")
    if kind == Kind.LINE and String(text_key).is_empty(): errors.append("line requires text_key")
    if kind == Kind.CHOICE and choice_text_keys.size() != choice_next_node_ids.size():
        errors.append("choice labels and destinations must have equal size")
    if condition != null: errors.append_array(condition.validate())
    for command in commands: errors.append_array(command.validate())
    return errors
