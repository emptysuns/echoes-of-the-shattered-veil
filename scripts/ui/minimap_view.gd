class_name MiniMapView
extends Control
## Compact explored-map projection; never owns exploration state.

var manifest: Dictionary = {}
var explored: Dictionary = {}
var player_position := Vector2i.ZERO

func set_data(floor_manifest: Dictionary, explored_tiles: Dictionary, player: Vector2i) -> void:
    manifest = floor_manifest
    explored = explored_tiles
    player_position = player
    queue_redraw()

func _draw() -> void:
    if manifest.is_empty(): return
    var width := int(manifest.width); var height := int(manifest.height)
    var scale := minf(size.x / width, size.y / height)
    var offset := (size - Vector2(width, height) * scale) * 0.5
    for point: Vector2i in explored.keys():
        var tile := DungeonGenerator.tile_at(manifest, point)
        var color := Color("4b6f8f") if tile != 0 else Color("19172c")
        draw_rect(Rect2(offset + Vector2(point) * scale, Vector2.ONE * maxf(1.0, scale)), color)
    draw_rect(Rect2(offset + Vector2(player_position) * scale, Vector2.ONE * maxf(1.0, scale)), Color("d59a42"))
