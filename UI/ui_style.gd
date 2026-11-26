extends RefCounted

# Shared look for the menu screens and the in-game buttons.

const FONT_PATH := "res://UI/fonts/Silkscreen-Regular.ttf"
const CREAM := Color(0.96, 0.94, 0.88)


# The font resource is shared, so only set its properties here. Calling
# clear_cache() would free glyph data other labels are still using.
static func apply_pixel_font(target: Control, size: int) -> void:
	var font := load(FONT_PATH) as FontFile
	if font == null:
		push_error("Missing pixel font: " + FONT_PATH)
		return
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.oversampling = 1.0
	target.add_theme_font_override("font", font)
	target.add_theme_font_size_override("font_size", size)
	target.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


static func style_button(target: Button, font_size: int = 22, bordered: bool = false) -> void:
	target.add_theme_font_size_override("font_size", font_size)
	target.add_theme_color_override("font_color", CREAM)
	target.add_theme_color_override("font_hover_color", Color.WHITE)
	target.add_theme_color_override("font_pressed_color", Color.WHITE)
	target.add_theme_color_override("font_focus_color", Color.WHITE)
	var normal := _panel(Color(0.10, 0.11, 0.14, 0.92), bordered)
	var hover := _panel(Color(0.18, 0.19, 0.24, 0.96), bordered)
	var pressed := _panel(Color(0.32, 0.28, 0.16, 0.96), bordered)
	target.add_theme_stylebox_override("normal", normal)
	target.add_theme_stylebox_override("hover", hover)
	target.add_theme_stylebox_override("pressed", pressed)
	target.add_theme_stylebox_override("focus", hover)


static func _panel(color: Color, bordered: bool) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(6)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	if bordered:
		box.border_color = Color(CREAM, 0.55)
		box.set_border_width_all(2)
	return box
