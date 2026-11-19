extends Node2D

# About 95% dark. Lights add back on top of this, so the beam can still read clearly.
const DARK := Color(0.05, 0.05, 0.06)

@onready var darkness: CanvasModulate = $CanvasModulate
@onready var button: Button = $UI/FlashlightButton
@onready var glow_button: Button = $UI/GlowButton

var flashlight: PointLight2D


func _ready() -> void:
	flashlight = get_parent().get_node("Player/Flashlight")
	_style_button(button)
	_style_button(glow_button)
	button.toggled.connect(_on_toggled)
	glow_button.toggled.connect(_on_glow_toggled)
	_apply(false)
	_apply_glow(false)


func _on_toggled(on: bool) -> void:
	_apply(on)


func _on_glow_toggled(on: bool) -> void:
	_apply_glow(on)


func _apply(on: bool) -> void:
	darkness.color = DARK if on else Color.WHITE
	flashlight.enabled = on
	button.text = "Flashlight on" if on else "Flashlight"


func _apply_glow(on: bool) -> void:
	flashlight.call("set_glow_enabled", on)
	glow_button.text = "Glow on" if on else "Glow"


func _style_button(target: Button) -> void:
	target.focus_mode = Control.FOCUS_NONE
	target.add_theme_font_size_override("font_size", 22)
	target.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
	target.add_theme_color_override("font_hover_color", Color.WHITE)
	var normal := _panel(Color(0.10, 0.11, 0.14, 0.92))
	var hover := _panel(Color(0.18, 0.19, 0.24, 0.96))
	var pressed := _panel(Color(0.32, 0.28, 0.16, 0.96))
	target.add_theme_stylebox_override("normal", normal)
	target.add_theme_stylebox_override("hover", hover)
	target.add_theme_stylebox_override("pressed", pressed)
	target.add_theme_stylebox_override("focus", normal)


func _panel(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = 6
	box.corner_radius_top_right = 6
	box.corner_radius_bottom_left = 6
	box.corner_radius_bottom_right = 6
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box
