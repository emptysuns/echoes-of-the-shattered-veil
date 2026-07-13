class_name StatusComponent
extends Node
## Stack/duration state; status definitions remain immutable content.

signal status_changed(status_id: StringName, stacks: int, duration: int)
var active: Dictionary = {}

func apply(status_id: StringName, duration_override := 0) -> bool:
    var definition := ContentRegistry.get_definition(status_id) as StatusEffectResource
    if definition == null: return false
    var key := String(status_id)
    var record: Dictionary = active.get(key, {"stacks": 0, "duration": 0})
    match definition.stack_mode:
        StatusEffectResource.StackMode.REFRESH:
            record.stacks = maxi(1, int(record.stacks))
            record.duration = maxi(definition.base_duration, duration_override)
        StatusEffectResource.StackMode.ADD_DURATION:
            record.stacks = maxi(1, int(record.stacks))
            record.duration = int(record.duration) + maxi(definition.base_duration, duration_override)
        StatusEffectResource.StackMode.ADD_STACK:
            record.stacks = mini(definition.max_stacks, int(record.stacks) + 1)
            record.duration = maxi(int(record.duration), maxi(definition.base_duration, duration_override))
        StatusEffectResource.StackMode.REPLACE:
            record = {"stacks": 1, "duration": maxi(definition.base_duration, duration_override)}
    active[key] = record
    status_changed.emit(status_id, int(record.stacks), int(record.duration))
    return true

func tick(timing: StatusEffectResource.TickTiming, owner: Node) -> void:
    var expired: Array[String] = []
    for key: String in active.keys():
        var definition := ContentRegistry.get_definition(StringName(key)) as StatusEffectResource
        if definition == null:
            expired.append(key)
            continue
        if definition.tick_timing != timing: continue
        var record: Dictionary = active[key]
        if not String(definition.periodic_effect_id).is_empty():
            for _stack in range(int(record.stacks)):
                CombatSystem.apply_effect(definition.periodic_effect_id, owner, owner)
        record.duration = int(record.duration) - 1
        active[key] = record
        if int(record.duration) <= 0: expired.append(key)
    for key in expired:
        active.erase(key)
        status_changed.emit(StringName(key), 0, 0)

func modifier(stat_name: StringName) -> int:
    var total := 0
    for key: String in active.keys():
        var definition := ContentRegistry.get_definition(StringName(key)) as StatusEffectResource
        if definition == null: continue
        var stacks := int((active[key] as Dictionary).stacks)
        if stat_name == &"attack": total += definition.attack_modifier * stacks
        elif stat_name == &"defense": total += definition.defense_modifier * stacks
        elif stat_name == &"speed": total += definition.speed_modifier * stacks
    return total
