extends PointLight2D

# Lantern cone along +X. Distances are in character-heights (the sprite is 1 tall).
# The body sits inside the back of the beam, the same way the reference lantern
# wraps the character, and the bright pool is the stretch of ground in front.
const CH := 36.0
const BACK := -0.3
const FRONT := 2.8


func _ready() -> void:
	# Cancels the player's scale of 2 so texture pixels map 1:1 with world pixels.
	scale = Vector2(0.5, 0.5)
	texture = _make_beam_texture()
	texture_scale = 64.0 / CH
	energy = 1.55
	color = Color(1.0, 0.96, 0.86)
	blend_mode = Light2D.BLEND_MODE_ADD
	enabled = false


func _process(_delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	if body == null:
		return
	var aim: Vector2 = body.get("last_direction")
	if aim.length_squared() < 0.001:
		aim = Vector2.RIGHT
	rotation = aim.angle()


func _make_beam_texture() -> Texture2D:
	var size := 256
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var origin := Vector2(size * 0.5, size * 0.5)
	for y in size:
		for x in size:
			var p := (Vector2(x + 0.5, y + 0.5) - origin) / CH
			var light := _shade(p.x, p.y)
			image.set_pixel(x, y, Color(light, light, light, light))
	return ImageTexture.create_from_image(image)


func _shade(x: float, y: float) -> float:
	var half := _half_width(x)
	if half <= 0.001:
		return 0.0
	var side := absf(y) / half
	if side >= 1.0:
		return 0.0
	var across := 1.0 - smoothstep(0.55, 1.0, side)
	return clampf(across * 0.85, 0.0, 1.0)


# Rounded cone: narrow just behind the sprite, widest ahead of it, round at the far end.
func _half_width(x: float) -> float:
	if x <= BACK or x >= FRONT:
		return 0.0
	var u := (x - BACK) / (FRONT - BACK)
	var body := pow(sin(u * PI), 0.36)
	var bias := 0.9 + 0.38 * pow(u, 0.75)
	return 1.58 * body * bias
