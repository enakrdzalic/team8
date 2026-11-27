extends Control

const UIStyle = preload("res://UI/ui_style.gd")

const STORY := "I was just a butcher living in a simple town, before it got overrun with terrifying monsters that terrorize us after the sun goes down. In order to feed the people of this town, I have taken it upon myself to venture out and harvest their meat."
const MAIN_SCENE := "res://main.tscn"
const CHAR_SECONDS := 0.036

@onready var story: Label = $Story
@onready var button: Button = $ContinueButton

var _tween: Tween
var _done := false
var _last_count := 0

func _ready() -> void:
	story.text = STORY
	story.visible_characters = 0
	UIStyle.apply_pixel_font(story, 32)
	UIStyle.style_button(button, 32, true)
	UIStyle.apply_pixel_font(button, 32)
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
	$UI_Click.post_event()
	Wwise.post_event("Stop_Intro_Music", $Intro_Music) 
	await get_tree().create_timer(0.5).timeout 
	button.disabled = true
	GameManager.new_game()
	GameManager.fade_from_black = true
	GameManager.set_state(GameManager.GameState.PLAYING)
	SceneManager.change_scene(MAIN_SCENE)
func _process(_delta: float) -> void:
	var count := story.visible_characters
	if count > _last_count:
		var letter := STORY.substr(count - 1, 1)
		if letter != " ":
			$UI_Typing.post_event()
		_last_count = count
