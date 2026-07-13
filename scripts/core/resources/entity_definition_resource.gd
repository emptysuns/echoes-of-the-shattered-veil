class_name EntityDefinitionResource
extends ContentDefinition
## Compositional actor definition consumed by ActorFactory.

@export var stats: StatBlockResource
@export var ai_profile: StringName = &"none"
@export var faction: StringName = &"neutral"
@export var texture_path: String
@export var component_ids: PackedStringArray = []
@export var action_ids: PackedStringArray = []
@export var drop_table_ids: PackedStringArray = []
@export var dialogue_id: StringName
@export var boss_phases: Array[BossPhaseResource] = []
@export var elite_chance: float = 0.0

func validate() -> PackedStringArray:
    var errors := super.validate()
    if stats == null: errors.append("stats resource is required")
    elif not stats.validate().is_empty(): errors.append("stats resource is invalid")
    if texture_path.is_empty() or not texture_path.begins_with("res://"):
        errors.append("texture_path must use res://")
    if elite_chance < 0.0 or elite_chance > 1.0: errors.append("elite_chance must be between zero and one")
    return errors
