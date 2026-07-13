class_name BiomeDefinitionResource
extends ContentDefinition
## Generation, palette, budget, and narrative tags for a biome.

@export_range(1, 99, 1) var act: int = 1
@export_range(1, 99, 1) var minimum_floor: int = 1
@export_range(1, 99, 1) var maximum_floor: int = 3
@export var wall_color: Color = Color("121126")
@export var floor_color: Color = Color("27234a")
@export var explored_color: Color = Color("17152b")
@export var spawn_entity_ids: PackedStringArray = []
@export var item_ids: PackedStringArray = []
@export var story_event_ids: PackedStringArray = []
@export var room_min_size: Vector2i = Vector2i(4, 4)
@export var room_max_size: Vector2i = Vector2i(9, 7)

func validate() -> PackedStringArray:
    var errors := super.validate()
    if maximum_floor < minimum_floor: errors.append("maximum_floor cannot precede minimum_floor")
    if room_min_size.x < 3 or room_min_size.y < 3: errors.append("room_min_size is too small")
    if room_max_size.x < room_min_size.x or room_max_size.y < room_min_size.y:
        errors.append("room_max_size must contain room_min_size")
    return errors
