class_name BossPhaseResource
extends ContentDefinition
## Declarative phase threshold and behavior change.

@export_range(0.0, 1.0, 0.01) var health_ratio_threshold: float = 1.0
@export var ai_profile: StringName = &"boss_melee"
@export var enter_effect_ids: PackedStringArray = []
@export var dialogue_node_id: StringName
@export var summon_entity_ids: PackedStringArray = []

func validate() -> PackedStringArray:
    var errors := super.validate()
    if health_ratio_threshold < 0.0 or health_ratio_threshold > 1.0:
        errors.append("health_ratio_threshold must be between zero and one")
    if String(ai_profile).is_empty(): errors.append("ai_profile is required")
    return errors
