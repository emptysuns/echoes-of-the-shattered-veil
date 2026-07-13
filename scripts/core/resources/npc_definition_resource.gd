class_name NPCDefinitionResource
extends ContentDefinition
## Recurring NPC presentation and relationship thresholds.

@export var portrait_path: String
@export var dialogue_ids: PackedStringArray = []
@export var relationship_track_id: StringName
@export var initial_relationship: int = 0
@export var survival_flag_id: StringName
@export var autonomy_flag_id: StringName
@export var gameplay_service: StringName

func validate() -> PackedStringArray:
    var errors := super.validate()
    if portrait_path.is_empty() or not portrait_path.begins_with("res://"):
        errors.append("portrait_path must use res://")
    if String(relationship_track_id).is_empty(): errors.append("relationship_track_id is required")
    return errors
