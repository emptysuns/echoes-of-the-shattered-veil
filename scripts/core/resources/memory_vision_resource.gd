class_name MemoryVisionResource
extends ContentDefinition
## Short pixel-tableau sequence authored as localized frames and cues.

@export var frame_text_keys: PackedStringArray = []
@export var frame_durations: PackedFloat32Array = []
@export var palette_id: StringName
@export var completion_commands: Array[NarrativeCommandResource] = []
@export var skippable := true

func validate() -> PackedStringArray:
    var errors := super.validate()
    if frame_text_keys.is_empty(): errors.append("vision requires at least one frame")
    if frame_text_keys.size() != frame_durations.size(): errors.append("vision text and durations must match")
    if String(palette_id).is_empty(): errors.append("palette_id is required")
    for command in completion_commands: errors.append_array(command.validate())
    return errors
