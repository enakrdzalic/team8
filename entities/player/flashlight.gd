extends PointLight2D

# Beam points along +X, then rotates to the player's last facing.
const BEAM_HALF_ANGLE := 0.52
const BEAM_REACH := 120.0
const GLOW_RADIUS := 36.0

var glow_enabled := false


func _ready() -> void:
	scale = Vector2(0.5, 0.5)
	texture = _make_beam_texture()
	texture_scale = 4.2
	energy = 1.35
	color = Color(1.0, 0.95, 0.82)
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


func set_glow_enabled(on: bool) -> void:
	glow_enabled = on
	texture = _make_beam_texture()


func _make_beam_texture() -> Texture2D:
	var size := 256
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size * 0.5, size * 0.5)
	for y in size:
		for x in size:
			var offset := Vector2(x + 0.5, y + 0.5) - center
			var dist := offset.length()
			var angle := absf(offset.angle())
			var beam := 0.0
			if dist < BEAM_REACH and angle < BEAM_HALF_ANGLE and offset.x > -4.0:
				var along := 1.0 - smoothstep(0.0, 1.0, dist / BEAM_REACH)
				var across := 1.0 - smoothstep(0.35, 1.0, angle / BEAM_HALF_ANGLE)
				beam = along * across
			var glow := 0.0
			if glow_enabled and dist < GLOW_RADIUS:
				glow = 1.0 - smoothstep(0.0, 1.0, dist / GLOW_RADIUS)
			var light := clampf(maxf(beam, glow * 0.9), 0.0, 1.0)
			image.set_pixel(x, y, Color(light, light, light, light))
	return ImageTexture.create_from_image(image)
