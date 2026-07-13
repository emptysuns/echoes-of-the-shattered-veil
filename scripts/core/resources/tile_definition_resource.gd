class_name TileDefinitionResource
extends ContentDefinition
## Logical tile properties independent of rendering.

@export var walkable: bool = true
@export var opaque: bool = false
@export var hazardous: bool = false
@export var damage: int = 0
@export var interaction_id: StringName

func validate() -> PackedStringArray:
    var errors := super.validate()
    if hazardous and damage <= 0: errors.append("hazardous tile requires positive damage")
    if opaque and walkable: errors.append("opaque walkable tiles require an explicit special primitive")
    return errors
