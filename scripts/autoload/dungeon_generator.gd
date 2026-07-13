extends Node
## Deterministic generation facade with manifest validation and StoryBeat facts.

const BSP_GENERATOR_SCRIPT := preload("res://scripts/dungeon/bsp_generator.gd")
const TILE_WALL := 0
var _generator: RefCounted = BSP_GENERATOR_SCRIPT.new()

func generate_floor(seed: int, floor_index: int, narrative_plan: Dictionary) -> Dictionary:
    var manifest: Dictionary = _generator.generate(seed, floor_index, narrative_plan)
    var errors := validate_manifest(manifest)
    if not errors.is_empty():
        Logger.error(&"dungeon", &"MANIFEST_INVALID", "Generated floor failed validation", {"errors": errors, "seed": seed, "floor": floor_index})
        return {}
    for placement: Dictionary in manifest.story_beats:
        var raw: Array = placement.room
        EventBus.story_beat_placed.emit(StringName(placement.beat_id), Rect2i(int(raw[0]), int(raw[1]), int(raw[2]), int(raw[3])))
    return manifest

func validate_manifest(manifest: Dictionary) -> PackedStringArray:
    var errors := PackedStringArray()
    var width := int(manifest.get("width", 0)); var height := int(manifest.get("height", 0))
    var tiles: Array = manifest.get("tiles", [])
    if width <= 0 or height <= 0: errors.append("invalid dimensions")
    if tiles.size() != width * height: errors.append("tile count does not match dimensions")
    var stories: Array = manifest.get("story_beats", [])
    if stories.size() < 1 or stories.size() > 2: errors.append("floor must contain one or two StoryBeats")
    if not manifest.has("start") or not manifest.has("exit"): errors.append("start and exit are required")
    if errors.is_empty() and not _is_connected(manifest): errors.append("walkable floor is disconnected")
    return errors

func tile_at(manifest: Dictionary, point: Vector2i) -> int:
    var width := int(manifest.width); var height := int(manifest.height)
    if point.x < 0 or point.y < 0 or point.x >= width or point.y >= height: return TILE_WALL
    return int((manifest.tiles as Array)[point.y * width + point.x])

func is_walkable(manifest: Dictionary, point: Vector2i) -> bool:
    return tile_at(manifest, point) != TILE_WALL

func is_opaque(manifest: Dictionary, point: Vector2i) -> bool:
    return tile_at(manifest, point) == TILE_WALL

func reveal_secret(manifest: Dictionary) -> void:
    var secret: Dictionary = manifest.get("secret", {})
    if secret.is_empty(): return
    secret.revealed = true
    manifest.secret = secret

func _is_connected(manifest: Dictionary) -> bool:
    var raw_start: Array = manifest.start
    var start := Vector2i(int(raw_start[0]), int(raw_start[1]))
    var visited := {start: true}; var queue: Array[Vector2i] = [start]
    while not queue.is_empty():
        var current: Vector2i = queue.pop_front()
        for direction in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
            var next: Vector2i = current + direction
            if not visited.has(next) and is_walkable(manifest, next): visited[next] = true; queue.append(next)
    for y in range(int(manifest.height)):
        for x in range(int(manifest.width)):
            var point := Vector2i(x, y)
            if is_walkable(manifest, point) and not visited.has(point): return false
    return true
