extends Node
## Owns typed story facts, relationships, beat scheduling, and narrative transactions.

var flags: Dictionary = {
    "base.flag.maelin_alive": true, "base.flag.ilyra_alive": true,
    "base.flag.vey_alive": true, "base.flag.oryn_alive": true, "base.flag.moth_alive": true,
}
var relationships: Dictionary = {"base.relationship.maelin": 0, "base.relationship.ilyra": 0, "base.relationship.vey": 0, "base.relationship.oryn": 0, "base.relationship.moth": 0}
var triggered_beats: PackedStringArray = []
var queued_visions: Array[StringName] = []

func evaluate_condition(condition: Variant) -> bool:
    if condition == null: return true
    if condition is ConditionResource:
        var resource := condition as ConditionResource
        match resource.kind:
            ConditionResource.Kind.ALWAYS: return true
            ConditionResource.Kind.ALL:
                return resource.children.all(func(child: ConditionResource) -> bool: return evaluate_condition(child))
            ConditionResource.Kind.ANY:
                return resource.children.any(func(child: ConditionResource) -> bool: return evaluate_condition(child))
            ConditionResource.Kind.NOT: return not evaluate_condition(resource.children[0])
            ConditionResource.Kind.FLAG_EQUALS: return bool(flags.get(String(resource.target_id), false)) == resource.expected_bool
            ConditionResource.Kind.RELATIONSHIP_AT_LEAST: return int(relationships.get(String(resource.target_id), 0)) >= resource.threshold
            ConditionResource.Kind.LORE_RATIO_AT_LEAST: return LoreSystem.completion_ratio() >= resource.threshold
            ConditionResource.Kind.META_AT_LEAST: return MetaProgressionSystem.memory_tier >= resource.threshold
            ConditionResource.Kind.NPC_ALIVE: return bool(flags.get(String(resource.target_id), false))
    if condition is Dictionary:
        var data := condition as Dictionary
        match String(data.get("type", "always")):
            "flag_equals": return flags.get(String(data.get("target", "")), false) == data.get("value", true)
            "meta_at_least":
                var meta_target := String(data.get("target", "memory_tier"))
                var meta_value := 0
                match meta_target:
                    "deaths": meta_value = MetaProgressionSystem.death_count
                    "memory_tier": meta_value = MetaProgressionSystem.memory_tier
                    "echo_essence": meta_value = MetaProgressionSystem.echo_essence
                    _: return false
                return meta_value >= int(data.get("value", 0))
            "relationship_at_least": return int(relationships.get(String(data.get("target", "")), 0)) >= int(data.get("value", 0))
            "lore_ratio_at_least": return LoreSystem.completion_ratio() >= float(data.get("value", 0.0))
    return true

func execute_json_commands(commands: Array) -> bool:
    var old_flags := flags.duplicate(true)
    var old_relationships := relationships.duplicate(true)
    for variant: Variant in commands:
        if not variant is Dictionary: continue
        var command := variant as Dictionary
        var target := String(command.get("target", ""))
        match String(command.get("type", "")):
            "set_flag": set_flag(target, command.get("value", true))
            "adjust_relationship": adjust_relationship(target, int(command.get("amount", 0)))
            "reveal_lore": LoreSystem.discover(target)
            "advance_quest": QuestSystem.advance_active(StringName(target))
            "queue_vision": queued_visions.append(StringName(target))
            "unlock_meta": MetaProgressionSystem.unlocks[target] = true
            "grant_item": InventorySystem.add_item(target, int(command.get("amount", 1)))
            "emit_message": EventBus.message_enqueued.emit(&"narrative", StringName(target), {})
            _:
                flags = old_flags
                relationships = old_relationships
                Logger.error(&"narrative", &"COMMAND_UNKNOWN", "Unknown narrative command", command)
                return false
    return true

func set_flag(flag_id: String, value: Variant) -> void:
    flags[flag_id] = value
    EventBus.story_flag_changed.emit(StringName(flag_id), value)

func adjust_relationship(track_id: String, delta: int) -> void:
    relationships[track_id] = clampi(int(relationships.get(track_id, 0)) + delta, -100, 100)

func build_floor_plan(floor_index: int) -> Dictionary:
    var candidates := ["base.story.act1.nave_missing_names", "base.story.act1.ash_clinic", "base.story.act1.bellmakers_cell"]
    var selected: Array[String] = []
    for offset in range(candidates.size()):
        var candidate: String = candidates[(floor_index - 1 + offset) % candidates.size()]
        if candidate not in triggered_beats:
            selected.append(candidate)
            break
    if selected.is_empty(): selected.append(candidates[(floor_index - 1) % candidates.size()])
    if floor_index >= 2:
        var optional: String = candidates[floor_index % candidates.size()]
        if optional not in selected: selected.append(optional)
    return {"required": selected[0], "optional": selected.slice(1), "floor": floor_index}

func trigger_beat(beat_id: StringName) -> void:
    if String(beat_id) not in triggered_beats: triggered_beats.append(String(beat_id))
    EventBus.story_beat_triggered.emit(beat_id)

func snapshot() -> Dictionary:
    return {"flags": flags.duplicate(true), "relationships": relationships.duplicate(true), "triggered_beats": Array(triggered_beats)}

func restore(data: Dictionary) -> void:
    if data.is_empty(): return
    flags = (data.get("flags", flags) as Dictionary).duplicate(true)
    relationships = (data.get("relationships", relationships) as Dictionary).duplicate(true)
    triggered_beats = PackedStringArray(data.get("triggered_beats", []))
