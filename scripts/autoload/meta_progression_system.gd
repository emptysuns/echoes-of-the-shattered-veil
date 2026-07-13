extends Node
## Persistent Echo Essence, memory tiers, backgrounds, and run archive.

var echo_essence := 0
var death_count := 0
var memory_tier := 0
var unlocks: Dictionary = {"background.ash_bound": true}
var run_archive: Array[Dictionary] = []

func _ready() -> void:
    restore(SaveSystem.load_profile())

func resolve_run(summary: Dictionary) -> int:
    var gained := Balance.essence_for_run(int(summary.get("floor", 1)), int(summary.get("defeated", 0)), int(summary.get("lore", 0)))
    echo_essence += gained
    death_count += 1
    run_archive.append(summary.duplicate(true))
    if run_archive.size() > 30: run_archive.pop_front()
    if death_count >= 1: memory_tier = maxi(memory_tier, 1)
    if int(summary.get("lore", 0)) >= 2: memory_tier = maxi(memory_tier, 2)
    if bool(summary.get("caedmon_restored", false)):
        unlocks["background.royal_penitent"] = true
        memory_tier = maxi(memory_tier, 3)
    EventBus.echo_essence_changed.emit(echo_essence, gained)
    SaveSystem.save_profile(snapshot())
    return gained

func spend_essence(amount: int, unlock_id: StringName) -> bool:
    if amount < 0 or echo_essence < amount or unlocks.has(String(unlock_id)): return false
    echo_essence -= amount
    unlocks[String(unlock_id)] = true
    EventBus.echo_essence_changed.emit(echo_essence, -amount)
    SaveSystem.save_profile(snapshot())
    return true

func snapshot() -> Dictionary:
    return {"echo_essence": echo_essence, "death_count": death_count, "memory_tier": memory_tier, "unlocks": unlocks.duplicate(true), "run_archive": run_archive.duplicate(true), "narrative": NarrativeSystem.snapshot(), "lore": LoreSystem.snapshot()}

func restore(data: Dictionary) -> void:
    if data.is_empty(): return
    echo_essence = int(data.get("echo_essence", 0))
    death_count = int(data.get("death_count", 0))
    memory_tier = int(data.get("memory_tier", 0))
    unlocks = (data.get("unlocks", unlocks) as Dictionary).duplicate(true)
    run_archive.assign(data.get("run_archive", []))
    NarrativeSystem.restore(data.get("narrative", {}))
    LoreSystem.restore(data.get("lore", {}))
