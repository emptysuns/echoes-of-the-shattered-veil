extends Node
## Traverses JSON dialogue graphs and exposes localized view models.

var dialogue_id: StringName
var graph: Dictionary = {}
var current_node_id := ""
var active := false

func start(target_dialogue_id: StringName) -> bool:
    graph = ContentRegistry.get_dialogue(target_dialogue_id)
    if graph.is_empty(): return false
    dialogue_id = target_dialogue_id
    current_node_id = String(graph.get("start_node", ""))
    active = true
    EventBus.dialogue_started.emit(dialogue_id)
    _emit_view()
    return true

func choose(index: int) -> bool:
    if not active: return false
    var node := _current_node()
    if String(node.get("type", "")) != "choice": return false
    var visible := _visible_choices(node)
    if index < 0 or index >= visible.size(): return false
    var choice: Dictionary = visible[index] as Dictionary
    NarrativeSystem.execute_json_commands(choice.get("commands", []))
    current_node_id = String(choice.get("next", ""))
    _advance_automatic_nodes()
    return true

func advance() -> void:
    if not active: return
    var node := _current_node()
    if String(node.get("type", "")) == "line":
        current_node_id = String(node.get("next", ""))
        _advance_automatic_nodes()

func current_view() -> Dictionary:
    if not active: return {}
    var node := _current_node()
    var view := {"dialogue_id": dialogue_id, "node_id": current_node_id, "type": String(node.get("type", "")), "speaker": String(node.get("speaker", "")), "text": ContentRegistry.text(StringName(node.get("text_key", ""))), "choices": []}
    for choice: Dictionary in _visible_choices(node):
        view.choices.append({"text": ContentRegistry.text(StringName(choice.get("text_key", "")))})
    return view

func _current_node() -> Dictionary:
    return ((graph.get("nodes", {}) as Dictionary).get(current_node_id, {}) as Dictionary)

func _visible_choices(node: Dictionary) -> Array:
    var result := []
    for choice: Variant in node.get("choices", []):
        if not choice is Dictionary: continue
        var conditions: Array = (choice as Dictionary).get("conditions", [])
        if conditions.all(func(condition: Variant) -> bool: return NarrativeSystem.evaluate_condition(condition)):
            result.append(choice)
    return result

func _advance_automatic_nodes() -> void:
    var node := _current_node()
    if String(node.get("type", "")) == "end" or node.is_empty():
        var ended_id := dialogue_id
        active = false
        EventBus.dialogue_ended.emit(ended_id)
        return
    NarrativeSystem.execute_json_commands(node.get("commands", []))
    _emit_view()

func _emit_view() -> void:
    EventBus.dialogue_updated.emit(current_view())
