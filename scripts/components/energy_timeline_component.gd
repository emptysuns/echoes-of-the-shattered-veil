class_name EnergyTimelineComponent
extends Node
## Integer energy accumulation for strict discrete scheduling.

var speed := 100
var energy := 0

func configure(value: int) -> void:
    speed = maxi(1, value)
    energy = 0

func gain(elapsed_units: int) -> int:
    energy += Balance.energy_gain(speed, elapsed_units)
    return energy

func is_ready() -> bool:
    return energy >= Balance.config.readiness_threshold

func consume(cost: int) -> bool:
    if cost <= 0 or energy < cost: return false
    energy -= cost
    return true

func force_ready() -> void:
    energy = maxi(energy, Balance.config.readiness_threshold)
