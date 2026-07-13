extends Node

func _ready() -> void:
    var error := _run()
    if error.is_empty():
        print("PASS dialogue, quest, lore, meta, and ending conditions")
        get_tree().quit(0)
    else:
        push_error(error)
        get_tree().quit(1)

func _run() -> String:
    NarrativeSystem.flags = {"base.flag.maelin_alive": true, "base.flag.ilyra_alive": true, "base.flag.vey_alive": true, "base.flag.oryn_alive": true, "base.flag.moth_alive": true}
    NarrativeSystem.relationships = {"base.relationship.maelin": 0, "base.relationship.ilyra": 0, "base.relationship.vey": 0, "base.relationship.oryn": 0, "base.relationship.moth": 0}
    LoreSystem.discovered.clear()
    QuestSystem.active.clear()
    MetaProgressionSystem.death_count = 0
    if not DialogueManager.start(&"base.dialogue.hub.maelin"): return "Maelin dialogue failed to start"
    DialogueManager.advance()
    var view := DialogueManager.current_view()
    if String(view.type) != "choice" or (view.choices as Array).size() < 2: return "branching choice view was not produced"
    if not DialogueManager.choose(0): return "dialogue choice failed"
    if not bool(NarrativeSystem.flags.get("base.flag.maelin_noticed_crack", false)): return "dialogue command did not set story flag"
    if not QuestSystem.start_quest(&"base.quest.act1.a_name_returned"): return "quest failed to start"
    if not QuestSystem.advance(&"base.quest.act1.a_name_returned", &"found_order"): return "valid quest transition failed"
    if QuestSystem.advance(&"base.quest.act1.a_name_returned", &"restored"): return "invalid quest transition was accepted"
    var lore_ids := [
        &"base.lore.act1.bellkeepers_inventory", &"base.lore.act1.burnt_triage_slate", &"base.lore.act1.recall_dates_removed", &"base.lore.act1.caedmon_order",
        &"base.lore.act1.lysa_paper_bird", &"base.lore.act1.wall_of_missing_names", &"base.lore.act1.mercy_calibration_hymn",
    ]
    for lore_id in lore_ids:
        if not LoreSystem.discover(lore_id): return "lore discovery failed: %s" % lore_id
    var initial := NarrativeSystem.qualified_endings()
    if initial.is_empty() or String(initial.back().content_id) != "base.ending.mend": return "Mend baseline ending missing"
    for flag in ["base.flag.caedmon_chose_after_restoration", "base.flag.ilyra_memory_not_forged", "base.flag.aster_echo_not_overwritten", "base.flag.maelin_autonomy", "base.flag.ilyra_autonomy", "base.flag.vey_autonomy", "base.flag.oryn_autonomy", "base.flag.moth_autonomy"]:
        NarrativeSystem.set_flag(flag, true)
    var qualified := NarrativeSystem.qualified_endings()
    if not qualified.any(func(ending: EndingResource) -> bool: return ending.content_id == &"base.ending.chorus"): return "Chorus did not qualify at 87.5% lore with all required flags"
    var old_essence := MetaProgressionSystem.echo_essence
    var gained := MetaProgressionSystem.resolve_run({"floor": 2, "defeated": 3, "lore": 7})
    if gained <= 0 or MetaProgressionSystem.echo_essence <= old_essence: return "meta progression did not grant Essence"
    return ""
