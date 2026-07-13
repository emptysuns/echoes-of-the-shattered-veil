class_name InventoryComponent
extends Node
## Entity-local inventory ownership handle.

var owner_inventory_id: StringName

func configure(inventory_id: StringName) -> void:
    owner_inventory_id = inventory_id

func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    if String(owner_inventory_id).is_empty(): errors.append("owner_inventory_id is required")
    return errors
