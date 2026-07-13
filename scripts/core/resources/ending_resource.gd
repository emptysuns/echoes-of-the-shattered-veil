class_name EndingResource
extends ContentDefinition
## Data-authored ending eligibility and variant requirements.

@export var priority: int = 0
@export_range(0.0, 1.0, 0.01) var minimum_lore_ratio: float = 0.0
@export var required_flags: PackedStringArray = []
@export var required_survivors: PackedStringArray = []
@export var required_autonomy: PackedStringArray = []
@export var condition: ConditionResource
@export var finale_scene_id: StringName

func validate() -> PackedStringArray:
    var errors := super.validate()
    if minimum_lore_ratio < 0.0 or minimum_lore_ratio > 1.0: errors.append("minimum_lore_ratio is invalid")
    if String(finale_scene_id).is_empty(): errors.append("finale_scene_id is required")
    if condition != null: errors.append_array(condition.validate())
    return errors
