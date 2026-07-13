class_name NarrativeTriggerComponent
extends Node
## Emits a stable StoryEvent ID when the declared local hook occurs.

@export var story_event_id: StringName
@export var one_shot := true
var consumed := false

func trigger() -> bool:
    if consumed and one_shot: return false
    if String(story_event_id).is_empty(): return false
    consumed = true
    NarrativeSystem.trigger_beat(story_event_id)
    return true
