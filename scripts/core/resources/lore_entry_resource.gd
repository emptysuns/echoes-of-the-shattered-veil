class_name LoreEntryResource
extends ContentDefinition
## Situated testimony with reveal and evidence metadata.

@export var body_key: StringName
@export var source_actor_id: StringName
@export var source_role: StringName
@export_range(1, 5, 1) var reveal_tier: int = 1
@export var act: int = 1
@export var corroborates: PackedStringArray = []
@export var contradicts: PackedStringArray = []
@export var recontextualizes: PackedStringArray = []
@export var canonical: bool = true

func validate() -> PackedStringArray:
    var errors := super.validate()
    if String(body_key).is_empty(): errors.append("body_key is required")
    if String(source_role).is_empty(): errors.append("source_role is required")
    return errors
