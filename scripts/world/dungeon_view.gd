class_name DungeonView
extends Node2D
## Pixel-perfect floor renderer; domain state is supplied by Main and services.

const TILE_SIZE := 32
var manifest: Dictionary = {}
var visible_tiles: Dictionary = {}
var explored: Dictionary = {}
var actors: Dictionary = {}
var palette := {
    "wall": Color("121126"), "floor": Color("27234a"), "explored_wall": Color("0e0d1b"),
    "explored_floor": Color("17152b"), "fog": Color("090812"), "amber": Color("d59a42"),
    "cyan": Color("83b6b3"), "blood": Color("6f2638"), "ash": Color("d8d2c4"),
}

func load_floor(floor_manifest: Dictionary) -> void:
    clear_actors()
    manifest = floor_manifest
    visible_tiles.clear(); explored.clear()
    queue_redraw()

func set_visibility(new_visible: Dictionary, new_explored: Dictionary) -> void:
    visible_tiles = new_visible
    explored = new_explored
    for actor: Actor in actors.values(): actor.visible = visible_tiles.has(actor.grid_position)
    queue_redraw()

func add_actor(actor: Actor) -> void:
    actors[String(actor.actor_id)] = actor
    add_child(actor)
    actor.visible = visible_tiles.is_empty() or visible_tiles.has(actor.grid_position)

func remove_actor(actor: Actor) -> void:
    actors.erase(String(actor.actor_id))
    if is_instance_valid(actor): actor.queue_free()

func clear_actors() -> void:
    for actor: Actor in actors.values():
        if is_instance_valid(actor): actor.queue_free()
    actors.clear()

func actor_at(point: Vector2i, excluded: Actor = null) -> Actor:
    for actor: Actor in actors.values():
        if actor != excluded and actor.is_alive() and actor.grid_position == point: return actor
    return null

func _draw() -> void:
    if manifest.is_empty(): return
    var width := int(manifest.width); var height := int(manifest.height)
    for y in range(height):
        for x in range(width):
            var point := Vector2i(x, y)
            var rect := Rect2(Vector2(point * TILE_SIZE), Vector2.ONE * TILE_SIZE)
            if not explored.has(point):
                draw_rect(rect, palette.fog)
                continue
            var tile := DungeonGenerator.tile_at(manifest, point)
            var lit := visible_tiles.has(point)
            var color: Color = palette.floor if tile != BSPGenerator.Tile.WALL else palette.wall
            if not lit: color = palette.explored_floor if tile != BSPGenerator.Tile.WALL else palette.explored_wall
            draw_rect(rect, color)
            if tile != BSPGenerator.Tile.WALL:
                draw_line(rect.position, rect.position + Vector2(TILE_SIZE - 1, 0), color.lightened(0.08), 1.0)
                draw_line(rect.position, rect.position + Vector2(0, TILE_SIZE - 1), color.lightened(0.04), 1.0)
            if lit:
                _draw_feature(tile, rect)
    if visible_tiles.is_empty(): return
    for item: Dictionary in manifest.get("items", []):
        var point := _array_to_point(item.position)
        if visible_tiles.has(point):
            var center := Vector2(point * TILE_SIZE) + Vector2(16, 16)
            draw_rect(Rect2(center - Vector2(4, 6), Vector2(8, 12)), palette.cyan)
            draw_rect(Rect2(center - Vector2(2, 3), Vector2(4, 6)), palette.ash)

func _draw_feature(tile: int, rect: Rect2) -> void:
    match tile:
        BSPGenerator.Tile.STAIRS:
            for step in range(4): draw_rect(Rect2(rect.position + Vector2(7 + step * 3, 8 + step * 4), Vector2(15 - step * 3, 2)), palette.cyan)
        BSPGenerator.Tile.TRAP:
            draw_line(rect.position + Vector2(8, 23), rect.position + Vector2(16, 9), palette.blood, 2)
            draw_line(rect.position + Vector2(24, 23), rect.position + Vector2(16, 9), palette.blood, 2)
        BSPGenerator.Tile.STORY:
            draw_circle(rect.position + Vector2(16, 16), 8, palette.amber)
            draw_circle(rect.position + Vector2(16, 16), 4, palette.wall)
        BSPGenerator.Tile.SECRET_DOOR:
            draw_rect(Rect2(rect.position + Vector2(5, 5), Vector2(22, 22)), palette.wall)
            draw_rect(Rect2(rect.position + Vector2(14, 14), Vector2(3, 3)), palette.amber)

func _array_to_point(raw: Array) -> Vector2i:
    return Vector2i(int(raw[0]), int(raw[1]))
