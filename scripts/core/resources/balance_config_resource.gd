class_name BalanceConfigResource
extends ContentDefinition
## Hot-reloadable balance constants; formulas live in Balance.

@export var readiness_threshold: int = 1000
@export var move_energy_cost: int = 1000
@export var melee_energy_cost: int = 1000
@export var ranged_energy_cost: int = 1200
@export var defense_reduction_per_point: float = 0.08
@export var critical_multiplier: float = 1.5
@export var base_essence_per_floor: int = 8

func validate() -> PackedStringArray:
    var errors := super.validate()
    if readiness_threshold <= 0: errors.append("readiness_threshold must be positive")
    if move_energy_cost <= 0 or melee_energy_cost <= 0: errors.append("action costs must be positive")
    if critical_multiplier < 1.0: errors.append("critical_multiplier cannot reduce damage")
    return errors
