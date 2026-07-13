class_name AIComponent
extends Node
## Selects an intent; it never mutates another actor directly.

var profile: StringName = &"none"
var patrol_index := 0
var summon_cooldown := 0
const PATROL_DIRECTIONS := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

func configure(ai_profile: StringName) -> void:
    profile = ai_profile

func choose_intent(owner_position: Vector2i, target_position: Vector2i, can_see_target: bool, health_ratio := 1.0) -> Dictionary:
    var delta := target_position - owner_position
    var distance := maxi(abs(delta.x), abs(delta.y))
    var step := Vector2i(signi(delta.x), signi(delta.y))
    match String(profile):
        "chase":
            return {"type": "attack", "target": target_position} if distance <= 1 else {"type": "move", "direction": step}
        "ranged":
            if can_see_target and distance <= 5: return {"type": "ranged", "target": target_position}
            return {"type": "move", "direction": step}
        "patrol":
            if can_see_target:
                return {"type": "attack", "target": target_position} if distance <= 1 else {"type": "move", "direction": step}
            var direction: Vector2i = PATROL_DIRECTIONS[patrol_index % PATROL_DIRECTIONS.size()]
            patrol_index += 1
            return {"type": "move", "direction": direction}
        "boss_caedmon":
            if summon_cooldown <= 0 and health_ratio <= 0.6:
                summon_cooldown = 4
                return {"type": "summon", "entity_id": &"base.enemy.ash_hound"}
            summon_cooldown -= 1
            if distance <= 1: return {"type": "attack", "target": target_position, "power": 2}
            if can_see_target and distance <= 5: return {"type": "ranged", "target": target_position, "power": 1}
            return {"type": "move", "direction": step}
        _:
            return {"type": "wait"}
