extends Camera2D

# City blocks from the reference map. The camera stays centered on the player
# and holds at the edge of the current zone. Walking into the next zone eases
# the view across instead of cutting through a narrow gate.
const CATCHUP := 14.0
const GLIDE := 4.2

const ZONES: Array[Rect2] = [
	Rect2(428, 212, 644, 300),
	Rect2(992, 436, 936, 728),
	Rect2(1864, 1068, 1112, 420),
	Rect2(1864, 1416, 1112, 652),
	Rect2(1040, 1100, 888, 416),
	Rect2(1040, 1452, 888, 616),
	Rect2(36, 1100, 1068, 968),
	Rect2(36, 2004, 1020, 860),
	Rect2(36, 2800, 1020, 728),
	Rect2(992, 2004, 800, 772),
	Rect2(992, 2712, 800, 736),
	Rect2(1728, 2004, 1232, 632),
	Rect2(1728, 2572, 1232, 684),
]

var current_zone := 0
var glide_speed := CATCHUP
var player: Node2D


func _ready() -> void:
	player = get_parent().get_node("Player")
	var player_camera := player.get_node_or_null("Camera2D")
	if player_camera:
		player_camera.enabled = false
	make_current()
	current_zone = _zone_containing(player.global_position, 0)
	global_position = _clamped(player.global_position, ZONES[current_zone])


func _process(delta: float) -> void:
	var pos := player.global_position
	var zone := _zone_containing(pos, current_zone)
	if zone != current_zone:
		current_zone = zone
		glide_speed = GLIDE
	else:
		glide_speed = lerpf(glide_speed, CATCHUP, 1.0 - exp(-2.0 * delta))
	var target := _clamped(pos, ZONES[current_zone])
	var blend := 1.0 - exp(-glide_speed * delta)
	global_position = global_position.lerp(target, blend)


func _zone_containing(point: Vector2, fallback: int) -> int:
	if fallback >= 0 and fallback < ZONES.size() and ZONES[fallback].has_point(point):
		return fallback
	var best := -1
	var best_area := INF
	for index in ZONES.size():
		var zone := ZONES[index]
		if zone.has_point(point) and zone.get_area() < best_area:
			best = index
			best_area = zone.get_area()
	if best >= 0:
		return best
	return fallback


func _clamped(point: Vector2, zone: Rect2) -> Vector2:
	var half := get_viewport_rect().size / zoom * 0.5
	var min_pos := zone.position + half
	var max_pos := zone.end - half
	var result := point
	if min_pos.x > max_pos.x:
		result.x = zone.get_center().x
	else:
		result.x = clampf(point.x, min_pos.x, max_pos.x)
	if min_pos.y > max_pos.y:
		result.y = zone.get_center().y
	else:
		result.y = clampf(point.y, min_pos.y, max_pos.y)
	return result
