extends Node
## Explicit quest-stage transitions.

var active: Dictionary = {}

func start_quest(quest_id: StringName) -> bool:
    var quest := ContentRegistry.get_definition(quest_id) as QuestResource
    if quest == null or active.has(String(quest_id)): return false
    active[String(quest_id)] = String(quest.start_step_id)
    EventBus.quest_stage_changed.emit(quest_id, quest.start_step_id)
    return true

func advance(quest_id: StringName, next_step_id: StringName) -> bool:
    var quest := ContentRegistry.get_definition(quest_id) as QuestResource
    if quest == null: return false
    var current_id := String(active.get(String(quest_id), quest.start_step_id))
    for step in quest.steps:
        if String(step.step_id) == current_id and String(next_step_id) in step.next_step_ids:
            active[String(quest_id)] = String(next_step_id)
            EventBus.quest_stage_changed.emit(quest_id, next_step_id)
            return true
    return false

func advance_active(next_step_id: StringName) -> bool:
    if active.is_empty(): return false
    return advance(StringName(active.keys()[0]), next_step_id)

func current_step(quest_id: StringName) -> StringName:
    return StringName(active.get(String(quest_id), ""))

func snapshot() -> Dictionary:
    return active.duplicate(true)

func restore(data: Dictionary) -> void:
    active = data.duplicate(true)
