extends Control

const INTRO_SCENE := "res://UI/intro.tscn"

@onready var button: Button = $BeginButton


func _ready() -> void:
	_style_button(button)
	button.pressed.connect(_on_begin_pressed)
	button.grab_focus()


func _on_begin_pressed() -> void:
	SceneManager.change_scene(INTRO_SCENE)


func _style_button(target: Button) -> void:
	target.add_theme_font_size_override("font_size", 28)
	target.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
	target.add_theme_color_override("font_hover_color", Color.WHITE)
	target.add_theme_color_override("font_pressed_color", Color.WHITE)
	target.add_theme_color_override("font_focus_color", Color.WHITE)
	var normal := _panel(Color(0.10, 0.11, 0.14, 0.92))
	var hover := _panel(Color(0.18, 0.19, 0.24, 0.96))
	var pressed := _panel(Color(0.32, 0.28, 0.16, 0.96))
	target.add_theme_stylebox_override("normal", normal)
	target.add_theme_stylebox_override("hover", hover)
	target.add_theme_stylebox_override("pressed", pressed)
	target.add_theme_stylebox_override("focus", hover)


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
