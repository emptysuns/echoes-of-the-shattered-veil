class_name BSPGenerator
extends RefCounted
## Deterministic BSP room/corridor generator with cellular edge variation.

enum Tile { WALL, FLOOR, STAIRS, TRAP, LORE, STORY, SECRET_DOOR }

const WIDTH := 41
const HEIGHT := 25
const MIN_LEAF := 8
const MAX_DEPTH := 4

var rng := RandomNumberGenerator.new()
var tiles: Array[int] = []
var rooms: Array[Rect2i] = []

func generate(seed: int, floor_index: int, narrative_plan: Dictionary) -> Dictionary:
    rng.seed = seed ^ (floor_index * 0x9E3779B1)
    tiles.resize(WIDTH * HEIGHT)
    tiles.fill(Tile.WALL)
    rooms.clear()
    _split(Rect2i(1, 1, WIDTH - 2, HEIGHT - 2), 0)
    rooms.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.position.x < b.position.x if a.position.x != b.position.x else a.position.y < b.position.y)
    _connect_rooms()
    _cellular_edge_variation()
    _seal_boundary()
    var first_room: Rect2i = rooms.front()
    var last_room: Rect2i = rooms.back()
    var start: Vector2i = first_room.get_center()
    var exit: Vector2i = last_room.get_center()
    _set_tile(exit, Tile.STAIRS)
    var story_beats := _inject_story_rooms(narrative_plan)
    var actors := _place_actors(floor_index, start, exit)
    var items := _place_items(floor_index, start)
    var traps := _place_traps(floor_index, start, exit)
    var secret := _place_secret_room(start)
    return {
        "seed": seed,
        "floor": floor_index,
        "width": WIDTH,
        "height": HEIGHT,
        "tiles": tiles.duplicate(),
        "rooms": rooms.map(func(room: Rect2i) -> Array[int]: return [room.position.x, room.position.y, room.size.x, room.size.y]),
        "start": [start.x, start.y],
        "exit": [exit.x, exit.y],
        "actors": actors,
        "items": items,
        "traps": traps,
        "story_beats": story_beats,
        "secret": secret,
    }

func _split(region: Rect2i, depth: int) -> void:
    if depth >= MAX_DEPTH or (region.size.x < MIN_LEAF * 2 and region.size.y < MIN_LEAF * 2):
        _carve_room(region)
        return
    var split_vertical := region.size.x > region.size.y
    if region.size.x > MIN_LEAF * 2 and region.size.y > MIN_LEAF * 2:
        split_vertical = rng.randf() < 0.5 if abs(region.size.x - region.size.y) < 5 else split_vertical
    if split_vertical and region.size.x >= MIN_LEAF * 2:
        var split_x := rng.randi_range(MIN_LEAF, region.size.x - MIN_LEAF)
        _split(Rect2i(region.position, Vector2i(split_x, region.size.y)), depth + 1)
        _split(Rect2i(region.position + Vector2i(split_x, 0), Vector2i(region.size.x - split_x, region.size.y)), depth + 1)
    elif region.size.y >= MIN_LEAF * 2:
        var split_y := rng.randi_range(MIN_LEAF, region.size.y - MIN_LEAF)
        _split(Rect2i(region.position, Vector2i(region.size.x, split_y)), depth + 1)
        _split(Rect2i(region.position + Vector2i(0, split_y), Vector2i(region.size.x, region.size.y - split_y)), depth + 1)
    else:
        _carve_room(region)

func _carve_room(region: Rect2i) -> void:
    var max_width := maxi(4, region.size.x - 2)
    var max_height := maxi(4, region.size.y - 2)
    var width := rng.randi_range(4, maxi(4, max_width))
    var height := rng.randi_range(4, maxi(4, max_height))
    var x := region.position.x + rng.randi_range(1, maxi(1, region.size.x - width - 1))
    var y := region.position.y + rng.randi_range(1, maxi(1, region.size.y - height - 1))
    var room := Rect2i(x, y, width, height)
    rooms.append(room)
    for py in range(room.position.y, room.end.y):
        for px in range(room.position.x, room.end.x): _set_tile(Vector2i(px, py), Tile.FLOOR)

func _connect_rooms() -> void:
    for index in range(1, rooms.size()):
        var from := rooms[index - 1].get_center()
        var to := rooms[index].get_center()
        if rng.randf() < 0.5:
            _carve_horizontal(from.x, to.x, from.y); _carve_vertical(from.y, to.y, to.x)
        else:
            _carve_vertical(from.y, to.y, from.x); _carve_horizontal(from.x, to.x, to.y)

func _carve_horizontal(x1: int, x2: int, y: int) -> void:
    for x in range(mini(x1, x2), maxi(x1, x2) + 1): _set_tile(Vector2i(x, y), Tile.FLOOR)

func _carve_vertical(y1: int, y2: int, x: int) -> void:
    for y in range(mini(y1, y2), maxi(y1, y2) + 1): _set_tile(Vector2i(x, y), Tile.FLOOR)

func _cellular_edge_variation() -> void:
    var carve: Array[Vector2i] = []
    for y in range(2, HEIGHT - 2):
        for x in range(2, WIDTH - 2):
            var point := Vector2i(x, y)
            if tile_at(point) != Tile.WALL: continue
            var floor_neighbors := 0
            for oy in range(-1, 2):
                for ox in range(-1, 2):
                    if ox == 0 and oy == 0: continue
                    if tile_at(point + Vector2i(ox, oy)) != Tile.WALL: floor_neighbors += 1
            if floor_neighbors >= 5 and rng.randf() < 0.38: carve.append(point)
    for point in carve: _set_tile(point, Tile.FLOOR)

func _inject_story_rooms(plan: Dictionary) -> Array[Dictionary]:
    var beat_ids: Array[String] = [String(plan.get("required", "base.story.act1.nave_missing_names"))]
    for optional_id: Variant in plan.get("optional", []): beat_ids.append(String(optional_id))
    beat_ids = beat_ids.slice(0, mini(2, beat_ids.size()))
    var placements: Array[Dictionary] = []
    for index in range(beat_ids.size()):
        var room_index := clampi(1 + index * 2, 0, rooms.size() - 1)
        var room := rooms[room_index]
        var center := room.get_center()
        _set_tile(center, Tile.STORY)
        placements.append({"beat_id": beat_ids[index], "room": [room.position.x, room.position.y, room.size.x, room.size.y], "position": [center.x, center.y], "required": index == 0})
    return placements

func _place_actors(floor_index: int, start: Vector2i, exit: Vector2i) -> Array[Dictionary]:
    var actors: Array[Dictionary] = []
    var sequence := 1
    if floor_index == 3:
        actors.append({"definition_id": "base.boss.caedmon_rook", "actor_id": "caedmon", "position": [exit.x, exit.y - 1], "sequence": sequence})
        return actors
    var pool := ["base.enemy.ash_hound", "base.enemy.bell_acolyte", "base.enemy.ash_sentinel"]
    var desired := 3 + floor_index * 2
    for room_index in range(1, rooms.size()):
        if actors.size() >= desired: break
        var room := rooms[room_index]
        var position := _random_floor_in_room(room, [start, exit])
        actors.append({"definition_id": pool[(room_index + floor_index) % pool.size()], "actor_id": "enemy-%d-%d" % [floor_index, sequence], "position": [position.x, position.y], "sequence": sequence})
        sequence += 1
    return actors

func _place_items(floor_index: int, start: Vector2i) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var ids := ["base.item.consumable.echo_tonic", "base.item.weapon.ashglass_sabre", "base.item.quest.lysa_paper_bird"]
    for index in range(mini(2 + floor_index / 2, rooms.size() - 1)):
        var position := _random_floor_in_room(rooms[rooms.size() - 1 - index], [start])
        result.append({"item_id": ids[(floor_index + index) % ids.size()], "position": [position.x, position.y]})
    return result

func _place_traps(floor_index: int, start: Vector2i, exit: Vector2i) -> Array[Array]:
    var result: Array[Array] = []
    for index in range(floor_index + 1):
        var room := rooms[(index + 1) % rooms.size()]
        var position := _random_floor_in_room(room, [start, exit])
        _set_tile(position, Tile.TRAP)
        result.append([position.x, position.y])
    return result

func _place_secret_room(start: Vector2i) -> Dictionary:
    if rooms.size() < 3: return {}
    var room := rooms[rooms.size() / 2]
    var position := room.position
    if position == start: position += Vector2i.ONE
    _set_tile(position, Tile.SECRET_DOOR)
    return {"room": [room.position.x, room.position.y, room.size.x, room.size.y], "door": [position.x, position.y], "revealed": false}

func _random_floor_in_room(room: Rect2i, excluded: Array[Vector2i]) -> Vector2i:
    for _attempt in range(20):
        var point := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
        if point not in excluded and tile_at(point) == Tile.FLOOR: return point
    return room.get_center()

func _seal_boundary() -> void:
    for x in range(WIDTH): _set_tile(Vector2i(x, 0), Tile.WALL); _set_tile(Vector2i(x, HEIGHT - 1), Tile.WALL)
    for y in range(HEIGHT): _set_tile(Vector2i(0, y), Tile.WALL); _set_tile(Vector2i(WIDTH - 1, y), Tile.WALL)

func tile_at(point: Vector2i) -> int:
    if point.x < 0 or point.y < 0 or point.x >= WIDTH or point.y >= HEIGHT: return Tile.WALL
    return tiles[point.y * WIDTH + point.x]

func _set_tile(point: Vector2i, value: int) -> void:
    if point.x >= 0 and point.y >= 0 and point.x < WIDTH and point.y < HEIGHT: tiles[point.y * WIDTH + point.x] = value
