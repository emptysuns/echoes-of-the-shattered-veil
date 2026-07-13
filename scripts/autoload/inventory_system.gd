extends Node
## Stack ownership, equipment, consumables, and affix receipts.

var items: Dictionary = {}
var equipment: Dictionary = {}
var affixes: Dictionary = {}

func reset_for_run() -> void:
    items = {"base.item.weapon.ashglass_sabre": 1, "base.item.armor.warden_coat": 1, "base.item.consumable.echo_tonic": 2}
    equipment = {ItemDefinitionResource.EquipSlot.MAIN_HAND: "base.item.weapon.ashglass_sabre", ItemDefinitionResource.EquipSlot.BODY: "base.item.armor.warden_coat"}
    affixes = {"base.item.weapon.ashglass_sabre": ["base.affix.remembered"]}

func add_item(item_id: String, amount := 1) -> bool:
    var definition := ContentRegistry.get_definition(StringName(item_id)) as ItemDefinitionResource
    if definition == null or amount <= 0: return false
    items[item_id] = mini(definition.max_stack, int(items.get(item_id, 0)) + amount)
    EventBus.item_acquired.emit(StringName(item_id), amount)
    return true

func remove_item(item_id: String, amount := 1) -> bool:
    if amount <= 0 or int(items.get(item_id, 0)) < amount: return false
    items[item_id] = int(items[item_id]) - amount
    if int(items[item_id]) <= 0: items.erase(item_id)
    return true

func equip(item_id: String) -> bool:
    var definition := ContentRegistry.get_definition(StringName(item_id)) as ItemDefinitionResource
    if definition == null or definition.equip_slot == ItemDefinitionResource.EquipSlot.NONE or not items.has(item_id): return false
    equipment[definition.equip_slot] = item_id
    EventBus.item_equipped.emit(StringName(item_id), definition.equip_slot)
    return true

func use_consumable(item_id: String, target: Node) -> bool:
    var definition := ContentRegistry.get_definition(StringName(item_id)) as ItemDefinitionResource
    if definition == null or definition.item_type != ItemDefinitionResource.ItemType.CONSUMABLE or not remove_item(item_id): return false
    for effect_id in definition.effect_ids:
        CombatSystem.apply_effect(StringName(effect_id), target, target)
    return true

func equipment_bonus(stat_name: StringName) -> int:
    var total := 0
    for item_id: String in equipment.values():
        var item := ContentRegistry.get_definition(StringName(item_id)) as ItemDefinitionResource
        if item == null: continue
        if stat_name == &"attack" and item.item_type == ItemDefinitionResource.ItemType.WEAPON: total += item.power
        if stat_name == &"defense" and item.item_type == ItemDefinitionResource.ItemType.ARMOR: total += item.power
        for affix_id: String in affixes.get(item_id, []):
            var affix := ContentRegistry.get_definition(StringName(affix_id)) as AffixDefinitionResource
            if affix == null: continue
            if stat_name == &"attack": total += affix.attack_bonus
            elif stat_name == &"defense": total += affix.defense_bonus
            elif stat_name == &"health": total += affix.health_bonus
    return total

func snapshot() -> Dictionary:
    return {"items": items.duplicate(true), "equipment": equipment.duplicate(true), "affixes": affixes.duplicate(true)}

func restore(data: Dictionary) -> void:
    if data.is_empty(): return
    items = (data.get("items", {}) as Dictionary).duplicate(true)
    equipment = (data.get("equipment", {}) as Dictionary).duplicate(true)
    affixes = (data.get("affixes", {}) as Dictionary).duplicate(true)
