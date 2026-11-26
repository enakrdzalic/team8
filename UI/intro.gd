extends Control

const STORY := "I was just a butcher living in a simple town, before it got overrun with terrifying monsters that terrorize us after the sun goes down. In order to feed the people of this town, I have taken it upon myself to venture out and harvest their meat."
const MAIN_SCENE := "res://main.tscn"
const FONT_PATH := "res://UI/fonts/Silkscreen-Regular.ttf"
const CHAR_SECONDS := 0.036

@onready var story: Label = $Story
@onready var button: Button = $ContinueButton

var _tween: Tween
var _done := false


func _ready() -> void:
	story.text = STORY
	story.visible_characters = 0
	_apply_pixel_font(story, 32)
	_style_button(button)
	_apply_pixel_font(button, 32)
	button.pressed.connect(_on_continue_pressed)
	_tween = create_tween()
	_tween.tween_interval(0.4)
	_tween.tween_property(story, "visible_characters", story.text.length(), story.text.length() * CHAR_SECONDS)
	_tween.finished.connect(_finish_typing)


func _input(event: InputEvent) -> void:
	if _done or not event.is_pressed() or event.is_echo():
		return
	var finish: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	finish = finish or event.is_action_pressed("ui_accept")
	if not finish:
		return
	_finish_typing()
	get_viewport().set_input_as_handled()


func _finish_typing() -> void:
	if _done:
		return
	_done = true
	if _tween != null and _tween.is_running():
		_tween.kill()
	story.visible_characters = story.text.length()
	button.visible = true
	button.modulate.a = 0.0
	button.grab_focus()
	var appear := create_tween()
	appear.tween_property(button, "modulate:a", 1.0, 0.2)


func _on_continue_pressed() -> void:
	button.disabled = true
	GameManager.fade_from_black = true
	GameManager.set_state(GameManager.GameState.PLAYING)
	SceneManager.change_scene(MAIN_SCENE)


func _apply_pixel_font(target: Control, size: int) -> void:
	var font := load(FONT_PATH) as FontFile
	if font == null:
		push_error("Missing pixel font: " + FONT_PATH)
		return
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.oversampling = 1.0
	#font.clear_cache()
	target.add_theme_font_override("font", font)
	target.add_theme_font_size_override("font_size", size)
	target.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _style_button(target: Button) -> void:
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
	box.border_color = Color(0.96, 0.94, 0.88, 0.55)
	box.set_border_width_all(2)
	return box
