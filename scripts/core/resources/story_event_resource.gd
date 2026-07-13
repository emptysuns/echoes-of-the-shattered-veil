class_name StoryEventResource
extends ContentDefinition
## StoryBeat eligibility, placement, and trigger commands.

@export var act: int = 1
@export var required: bool = false
@export var room_tag: StringName
@export var minimum_floor: int = 1
@export var maximum_floor: int = 99
@export var cooldown_floors: int = 1
@export var exclusion_group: StringName
@export var fallback_room_id: StringName
@export var condition: ConditionResource
@export var commands: Array[NarrativeCommandResource] = []

func validate() -> PackedStringArray:
    var errors := super.validate()
    if maximum_floor < minimum_floor: errors.append("invalid floor range")
    if String(room_tag).is_empty(): errors.append("room_tag is required")
    if required and String(fallback_room_id).is_empty(): errors.append("required event needs fallback_room_id")
    if condition != null: errors.append_array(condition.validate())
    for command in commands: errors.append_array(command.validate())
    return errors
