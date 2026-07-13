extends Node

func _ready() -> void:
    var error := _run()
    if error.is_empty():
        print("PASS deterministic connected dungeon with narrative injection")
        get_tree().quit(0)
    else:
        push_error(error)
        get_tree().quit(1)

func _run() -> String:
    var plan := {"required": "base.story.act1.nave_missing_names", "optional": ["base.story.act1.ash_clinic"]}
    var first := DungeonGenerator.generate_floor(424242, 2, plan)
    var second := DungeonGenerator.generate_floor(424242, 2, plan)
    if first.is_empty(): return "generator returned an empty manifest"
    if JSON.stringify(first) != JSON.stringify(second): return "same seed did not produce identical manifest"
    var errors := DungeonGenerator.validate_manifest(first)
    if not errors.is_empty(): return "manifest errors: %s" % errors
    if (first.story_beats as Array).size() != 2: return "expected required and optional StoryBeat"
    if String((first.story_beats as Array)[0].beat_id) != "base.story.act1.nave_missing_names": return "required StoryBeat was not injected"
    if (first.actors as Array).size() < 3: return "enemy budget not populated"
    if (first.traps as Array).is_empty() or (first.secret as Dictionary).is_empty(): return "trap or secret content missing"
    var boss_floor := DungeonGenerator.generate_floor(424242, 3, {"required": "base.story.act1.bellmakers_cell", "optional": []})
    if not (boss_floor.actors as Array).any(func(actor: Dictionary) -> bool: return actor.definition_id == "base.boss.caedmon_rook"):
        return "Act I boss was not placed on floor three"
    return ""
