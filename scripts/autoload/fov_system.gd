extends Node
## Recursive shadowcasting field of view with caller-owned opacity.

const MULTIPLIERS := [
    [1, 0, 0, 1], [0, 1, 1, 0], [0, -1, 1, 0], [-1, 0, 0, 1],
    [-1, 0, 0, -1], [0, -1, -1, 0], [0, 1, -1, 0], [1, 0, 0, -1],
]

func compute(origin: Vector2i, radius: int, is_opaque: Callable) -> Dictionary:
    var visible := {origin: true}
    for octant in range(8):
        var m: Array = MULTIPLIERS[octant]
        _cast_light(visible, origin, 1, 1.0, 0.0, radius, int(m[0]), int(m[1]), int(m[2]), int(m[3]), is_opaque)
    return visible

func has_line_of_sight(from: Vector2i, to: Vector2i, is_opaque: Callable) -> bool:
    var points := _bresenham(from, to)
    for index in range(1, points.size() - 1):
        if is_opaque.call(points[index]): return false
    return true

func _cast_light(visible: Dictionary, origin: Vector2i, row: int, start_slope: float, end_slope: float, radius: int, xx: int, xy: int, yx: int, yy: int, is_opaque: Callable) -> void:
    if start_slope < end_slope: return
    var next_start := start_slope
    var blocked := false
    for distance in range(row, radius + 1):
        var delta_y := -distance
        for delta_x in range(-distance, 1):
            var left_slope := (delta_x - 0.5) / (delta_y + 0.5)
            var right_slope := (delta_x + 0.5) / (delta_y - 0.5)
            if start_slope < right_slope: continue
            if end_slope > left_slope: break
            var current := Vector2i(origin.x + delta_x * xx + delta_y * xy, origin.y + delta_x * yx + delta_y * yy)
            if delta_x * delta_x + delta_y * delta_y <= radius * radius: visible[current] = true
            var opaque: bool = is_opaque.call(current)
            if blocked:
                if opaque:
                    next_start = right_slope
                    continue
                blocked = false
                start_slope = next_start
            elif opaque and distance < radius:
                blocked = true
                _cast_light(visible, origin, distance + 1, start_slope, left_slope, radius, xx, xy, yx, yy, is_opaque)
                next_start = right_slope
        if blocked: break

func _bresenham(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    var points: Array[Vector2i] = []
    var x0: int = from.x; var y0: int = from.y; var x1: int = to.x; var y1: int = to.y
    var dx: int = absi(x1 - x0); var sx: int = 1 if x0 < x1 else -1
    var dy: int = -absi(y1 - y0); var sy: int = 1 if y0 < y1 else -1
    var error: int = dx + dy
    while true:
        points.append(Vector2i(x0, y0))
        if x0 == x1 and y0 == y1: break
        var twice: int = 2 * error
        if twice >= dy: error += dy; x0 += sx
        if twice <= dx: error += dx; y0 += sy
    return points
