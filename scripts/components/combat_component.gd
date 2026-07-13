class_name CombatComponent
extends Node
## Local combat snapshot derived from an EntityDefinition.

var base_attack := 1
var base_defense := 0
var critical_chance := 0
var attack_range := 1
var action_ids: PackedStringArray = []

func configure(stats: StatBlockResource, actions: PackedStringArray) -> void:
    base_attack = stats.attack
    base_defense = stats.defense
    critical_chance = stats.critical_chance
    attack_range = stats.attack_range
    action_ids = actions.duplicate()

func attack_value(include_player_equipment := false) -> int:
    return base_attack + (InventorySystem.equipment_bonus(&"attack") if include_player_equipment else 0)

func defense_value(include_player_equipment := false) -> int:
    return base_defense + (InventorySystem.equipment_bonus(&"defense") if include_player_equipment else 0)
