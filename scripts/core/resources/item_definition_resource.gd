class_name ItemDefinitionResource
extends ContentDefinition
## Item, equipment, consumable, or narrative-object definition.

enum ItemType { MISC, WEAPON, ARMOR, CONSUMABLE, QUEST }
enum EquipSlot { NONE, MAIN_HAND, BODY, CHARM }

@export var item_type: ItemType = ItemType.MISC
@export var equip_slot: EquipSlot = EquipSlot.NONE
@export_range(1, 99, 1) var max_stack: int = 1
@export var power: int = 0
@export_range(0, 4, 1) var affix_slots: int = 0
@export var effect_ids: PackedStringArray = []
@export var texture_path: String
@export var essence_value: int = 0

func validate() -> PackedStringArray:
    var errors := super.validate()
    if max_stack < 1: errors.append("max_stack must be positive")
    if item_type in [ItemType.WEAPON, ItemType.ARMOR] and equip_slot == EquipSlot.NONE:
        errors.append("equipment requires an equip_slot")
    if not texture_path.is_empty() and not texture_path.begins_with("res://"):
        errors.append("texture_path must use res://")
    return errors
