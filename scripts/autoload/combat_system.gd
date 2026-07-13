extends Node
## Deterministic action validation and effect resolution.

var rng := RandomNumberGenerator.new()

func begin_run(seed: int) -> void:
    rng.seed = seed ^ 0xC0B417

func resolve_attack(attacker: Node, target: Node, power := 0, ranged := false) -> Dictionary:
    if attacker == null or target == null or not attacker.has_method("get_attack") or not target.has_method("get_defense"):
        return {"success": false, "reason": "invalid actor interface"}
    var critical := rng.randi_range(1, 100) <= int(attacker.get_critical_chance())
    var damage := Balance.damage_after_defense(int(attacker.get_attack()), int(target.get_defense()), power, critical)
    target.take_damage(damage, attacker)
    var receipt := {"success": true, "attacker": attacker.actor_id, "target": target.actor_id, "damage": damage, "critical": critical, "ranged": ranged}
    EventBus.damage_resolved.emit(receipt)
    EventBus.action_committed.emit(receipt)
    return receipt

func apply_effect(effect_id: StringName, source: Node, target: Node) -> bool:
    var effect := ContentRegistry.get_definition(effect_id) as EffectDefinitionResource
    if effect == null or target == null: return false
    match effect.effect_type:
        EffectDefinitionResource.EffectType.DAMAGE:
            if target.has_method("take_damage"): target.take_damage(maxi(1, effect.magnitude), source)
        EffectDefinitionResource.EffectType.HEAL:
            if target.has_method("heal"): target.heal(effect.magnitude)
        EffectDefinitionResource.EffectType.APPLY_STATUS:
            if target.has_method("apply_status"): target.apply_status(effect.target_id, effect.duration_turns)
        EffectDefinitionResource.EffectType.MODIFY_ENERGY:
            if target.has_method("modify_energy"): target.modify_energy(effect.magnitude)
        EffectDefinitionResource.EffectType.REVEAL_LORE:
            LoreSystem.discover(effect.target_id)
        _: return false
    return true
