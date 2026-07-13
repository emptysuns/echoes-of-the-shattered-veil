extends Node
## Presentation coordinator; authoritative state remains in domain services.

var overlay_stack: Array[StringName] = []

func open_overlay(overlay_id: StringName, payload := {}) -> void:
    if overlay_id not in overlay_stack: overlay_stack.append(overlay_id)
    EventBus.overlay_requested.emit(overlay_id, payload)

func close_overlay(overlay_id: StringName) -> void:
    overlay_stack.erase(overlay_id)

func has_modal() -> bool:
    return not overlay_stack.is_empty() or DialogueManager.active
