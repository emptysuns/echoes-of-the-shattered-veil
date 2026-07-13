class_name QuestResource
extends ContentDefinition
## Validated quest transition graph.

@export var start_step_id: StringName
@export var steps: Array[QuestStepResource] = []

func validate() -> PackedStringArray:
    var errors := super.validate()
    var ids := {}
    for step in steps:
        errors.append_array(step.validate())
        if ids.has(step.step_id): errors.append("duplicate quest step: %s" % step.step_id)
        ids[step.step_id] = true
    if not ids.has(start_step_id): errors.append("start_step_id does not exist")
    for step in steps:
        for next_id in step.next_step_ids:
            if not ids.has(next_id): errors.append("unknown quest successor: %s" % next_id)
    return errors
