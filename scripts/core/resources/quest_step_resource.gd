class_name QuestStepResource
extends Resource
## Explicit node in a quest transition graph.

@export var step_id: StringName
@export var text_key: StringName
@export var next_step_ids: PackedStringArray = []
@export var terminal: bool = false
@export var condition: ConditionResource
@export var commands: Array[NarrativeCommandResource] = []

func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    if String(step_id).is_empty(): errors.append("step_id is required")
    if String(text_key).is_empty(): errors.append("text_key is required")
    if terminal and not next_step_ids.is_empty(): errors.append("terminal step cannot have successors")
    return errors
