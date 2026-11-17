extends Camera2D

# Four forest zones in a loop. The camera stays centered on the player and
# clamps to the current zone. Crossing a path gate swooshes the view into
# the zone on the other side, then the same clamp applies there.
const SWOOSH_TIME := 0.6

const ZONES: Array[Rect2] = [
	Rect2(0, 0, 1280, 768),       # 0 northwest woods
	Rect2(1280, 0, 1280, 768),    # 1 northeast clearing
	Rect2(0, 768, 1280, 768),     # 2 southwest grove
	Rect2(1280, 768, 1280, 768),  # 3 southeast crossroads
]

# Path gates. "vertical" is a vertical line (east/west crossing).
# low/high are the zone indexes on either side of the line.
const DOORS: Array[Dictionary] = [
	{"vertical": true, "pos": 1280.0, "min": 336.0, "max": 432.0, "low": 0, "high": 1},
	{"vertical": true, "pos": 1280.0, "min": 1104.0, "max": 1200.0, "low": 2, "high": 3},
	{"vertical": false, "pos": 768.0, "min": 576.0, "max": 672.0, "low": 0, "high": 2},
	{"vertical": false, "pos": 768.0, "min": 1856.0, "max": 1952.0, "low": 1, "high": 3},
]

var current_zone := 0
var swoosh_from_zone := 0
var swoosh_to_zone := 0
var swoosh_t := 1.0
var transition_door := -1
var transition_dir := 0
var previous_position := Vector2.ZERO
var player: Node2D


func _ready() -> void:
	player = get_parent().get_node("Player")
	var player_camera := player.get_node_or_null("Camera2D")
	if player_camera:
		player_camera.enabled = false
	make_current()
	previous_position = player.global_position
	current_zone = _zone_containing(previous_position, 0)
	global_position = _clamped(previous_position, ZONES[current_zone])


func _process(delta: float) -> void:
	var pos := player.global_position
	if swoosh_t < 1.0:
		if _reverse_cross(previous_position, pos):
			swoosh_t = 1.0 - swoosh_t
			var swap := swoosh_from_zone
			swoosh_from_zone = swoosh_to_zone
			swoosh_to_zone = swap
			transition_dir *= -1
		swoosh_t = minf(1.0, swoosh_t + delta / SWOOSH_TIME)
		var blend := _ease(swoosh_t)
		var from_pos := _clamped(pos, ZONES[swoosh_from_zone])
		var to_pos := _clamped(pos, ZONES[swoosh_to_zone])
		global_position = from_pos.lerp(to_pos, blend)
		if swoosh_t >= 1.0:
			current_zone = _zone_containing(pos, swoosh_to_zone)
		previous_position = pos
		return

	_try_start(previous_position, pos)
	previous_position = pos
	if swoosh_t < 1.0:
		global_position = _clamped(pos, ZONES[swoosh_from_zone])
		return
	global_position = _clamped(pos, ZONES[current_zone])


func _try_start(prev: Vector2, pos: Vector2) -> void:
	for index in DOORS.size():
		var direction := _cross(prev, pos, DOORS[index])
		if direction == 0:
			continue
		var door: Dictionary = DOORS[index]
		var leaving: int = door["low"] if direction > 0 else door["high"]
		var entering: int = door["high"] if direction > 0 else door["low"]
		if current_zone != leaving:
			continue
		swoosh_from_zone = leaving
		swoosh_to_zone = entering
		transition_door = index
		transition_dir = direction
		swoosh_t = 0.0
		return


func _reverse_cross(prev: Vector2, pos: Vector2) -> bool:
	if transition_door < 0:
		return false
	return _cross(prev, pos, DOORS[transition_door]) == -transition_dir


func _cross(prev: Vector2, pos: Vector2, door: Dictionary) -> int:
	if door["vertical"]:
		if pos.y < door["min"] or pos.y > door["max"]:
			return 0
		if prev.y < door["min"] or prev.y > door["max"]:
			return 0
		if prev.x < door["pos"] and pos.x >= door["pos"]:
			return 1
		if prev.x >= door["pos"] and pos.x < door["pos"]:
			return -1
		return 0
	if pos.x < door["min"] or pos.x > door["max"]:
		return 0
	if prev.x < door["min"] or prev.x > door["max"]:
		return 0
	if prev.y < door["pos"] and pos.y >= door["pos"]:
		return 1
	if prev.y >= door["pos"] and pos.y < door["pos"]:
		return -1
	return 0


func _zone_containing(point: Vector2, fallback: int) -> int:
	for index in ZONES.size():
		if ZONES[index].has_point(point):
			return index
	return fallback


func _clamped(point: Vector2, zone: Rect2) -> Vector2:
	var half := get_viewport_rect().size / zoom * 0.5
	var min_pos := zone.position + half
	var max_pos := zone.end - half
	var result := point
	if min_pos.x > max_pos.x:
		result.x = zone.position.x + zone.size.x * 0.5
	else:
		result.x = clampf(point.x, min_pos.x, max_pos.x)
	if min_pos.y > max_pos.y:
		result.y = zone.position.y + zone.size.y * 0.5
	else:
		result.y = clampf(point.y, min_pos.y, max_pos.y)
	return result


func _ease(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
