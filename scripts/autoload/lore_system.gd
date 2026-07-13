extends Node
## Canonical discoveries and Codex read models.

const CANONICAL_TOTAL := 8
var discovered: PackedStringArray = []

func discover(lore_id: StringName) -> bool:
    if String(lore_id) in discovered: return false
    var definition := ContentRegistry.get_definition(lore_id)
    if not definition is LoreEntryResource: return false
    discovered.append(String(lore_id))
    EventBus.lore_discovered.emit(lore_id)
    EventBus.message_enqueued.emit(&"narrative", &"message.lore_found", {})
    return true

func completion_ratio() -> float:
    return minf(1.0, float(discovered.size()) / CANONICAL_TOTAL)

func entries() -> Array[LoreEntryResource]:
    var result: Array[LoreEntryResource] = []
    for lore_id in discovered:
        var definition := ContentRegistry.get_definition(StringName(lore_id))
        if definition is LoreEntryResource: result.append(definition as LoreEntryResource)
    return result

func snapshot() -> Dictionary:
    return {"discovered": Array(discovered)}

func restore(data: Dictionary) -> void:
    discovered = PackedStringArray(data.get("discovered", []))
