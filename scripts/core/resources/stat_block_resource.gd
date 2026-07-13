class_name StatBlockResource
extends ContentDefinition
## Base combat and scheduling values for an actor.

@export_range(1, 9999, 1) var max_health: int = 10
@export_range(0, 999, 1) var attack: int = 2
@export_range(0, 999, 1) var defense: int = 0
@export_range(1, 500, 1) var speed: int = 100
@export_range(0, 20, 1) var vision_range: int = 7
@export_range(0, 20, 1) var attack_range: int = 1
@export_range(0, 100, 1) var critical_chance: int = 5

func validate() -> PackedStringArray:
    var errors := super.validate()
    if max_health <= 0: errors.append("max_health must be positive")
    if speed <= 0: errors.append("speed must be positive")
    if attack_range < 1: errors.append("attack_range must be at least one")
    return errors
