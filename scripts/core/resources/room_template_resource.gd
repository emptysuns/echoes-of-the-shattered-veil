class_name RoomTemplateResource
extends ContentDefinition
## Handcrafted logical room template for narrative injection.

@export var room_tag: StringName
@export var layout: PackedStringArray = []
@export var minimum_floor: int = 1
@export var maximum_floor: int = 99
@export var minimum_entrances: int = 1
@export var secret: bool = false
@export var interaction_id: StringName

func validate() -> PackedStringArray:
    var errors := super.validate()
    if layout.is_empty(): errors.append("layout cannot be empty")
    else:
        var width := layout[0].length()
        for row in layout:
            if row.length() != width: errors.append("layout rows must have equal width")
    if String(room_tag).is_empty(): errors.append("room_tag is required")
    return errors
