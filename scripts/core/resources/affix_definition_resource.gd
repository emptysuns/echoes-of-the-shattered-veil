class_name AffixDefinitionResource
extends ContentDefinition
## Data-only procedural item modifier.

@export_range(1, 10, 1) var tier: int = 1
@export_range(0, 100, 1) var budget_cost: int = 1
@export var allowed_item_tags: PackedStringArray = []
@export var exclusion_group: StringName
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var health_bonus: int = 0
@export var granted_effect_ids: PackedStringArray = []

func validate() -> PackedStringArray:
    var errors := super.validate()
    if allowed_item_tags.is_empty(): errors.append("allowed_item_tags cannot be empty")
    if budget_cost < 0: errors.append("budget_cost cannot be negative")
    return errors
