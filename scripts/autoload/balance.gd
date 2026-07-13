extends Node
## Pure balance formulas backed by a hot-reloadable Resource snapshot.

const CONFIG_PATH := "res://resources/balance/default.tres"
var config: BalanceConfigResource

func _ready() -> void:
    reload_config()

func reload_config() -> bool:
    var candidate := load(CONFIG_PATH) as BalanceConfigResource
    if candidate == null or not candidate.validate().is_empty():
        Logger.error(&"balance", &"BALANCE_INVALID", "Balance configuration failed validation")
        return false
    config = candidate
    return true

func damage_after_defense(attack: int, defense: int, power := 0, critical := false) -> int:
    var raw := maxi(1, attack + power)
    var reduction := clampf(defense * config.defense_reduction_per_point, 0.0, 0.75)
    var result := maxi(1, roundi(raw * (1.0 - reduction)))
    if critical: result = maxi(1, roundi(result * config.critical_multiplier))
    return result

func energy_gain(speed: int, elapsed_units: int) -> int:
    return maxi(0, speed * elapsed_units)

func essence_for_run(floor_index: int, defeated_count: int, lore_count: int) -> int:
    return maxi(1, floor_index * config.base_essence_per_floor + defeated_count + lore_count * 2)

func enemy_budget(floor_index: int) -> int:
    return 6 + floor_index * 4
