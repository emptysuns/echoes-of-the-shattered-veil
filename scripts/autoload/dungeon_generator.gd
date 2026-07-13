extends Node
## Deterministic floor generation service. Spatial algorithms live in scripts/dungeon/.

func generate_floor(seed: int, floor_index: int, narrative_plan: Dictionary) -> Dictionary:
    return {"seed": seed, "floor": floor_index, "width": 31, "height": 19, "tiles": [], "rooms": [], "actors": [], "items": [], "story_plan": narrative_plan.duplicate(true)}
