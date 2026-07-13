class_name HealthComponent
extends Node
## Owns local health only; CombatSystem resolves damage values.

signal health_changed(current: int, maximum: int)
signal depleted(source: Node)

var maximum := 1
var current := 1

func configure(max_health: int) -> void:
    maximum = maxi(1, max_health)
    current = maximum
    health_changed.emit(current, maximum)

func damage(amount: int, source: Node = null) -> int:
    var applied := mini(current, maxi(0, amount))
    current -= applied
    health_changed.emit(current, maximum)
    if current <= 0: depleted.emit(source)
    return applied

func heal(amount: int) -> int:
    var before := current
    current = mini(maximum, current + maxi(0, amount))
    health_changed.emit(current, maximum)
    return current - before

func ratio() -> float:
    return float(current) / maximum
