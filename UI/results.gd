extends Control

const UIStyle = preload("res://UI/ui_style.gd")

const MAIN_SCENE := "res://main.tscn"
const CHAR_SECONDS := 0.03

@onready var report: Label = $Report
@onready var button: Button = $NextButton

var _tween: Tween
var _done := false
var _last_count := 0
var _in_money := false

func _ready() -> void:
	report.text = _build_report()
	report.visible_characters = 0
	UIStyle.apply_pixel_font(report, 32)
	UIStyle.style_button(button, 32, true)
	UIStyle.apply_pixel_font(button, 32)
	button.pressed.connect(_on_next_pressed)
	_tween = create_tween()
	_tween.tween_interval(0.4)
	_tween.tween_property(report, "visible_characters", report.text.length(), report.text.length() * CHAR_SECONDS)
	_tween.finished.connect(_finish_typing)


func _build_report() -> String:
	var lines: PackedStringArray = [
		"Night %d complete" % GameManager.night,
		"",
		"Monsters killed: %d  ->  $%d" % [GameManager.monsters_killed, GameManager.kill_earnings()],
		"Monsters dragged: %d  ->  $%d" % [GameManager.monsters_dragged, GameManager.drag_earnings()],
		"",
		"Total money: $%d" % GameManager.total_money,
	]
	return "\n".join(lines)


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
	report.visible_characters = report.text.length()
	button.visible = true
	button.modulate.a = 0.0
	button.grab_focus()
	var appear := create_tween()
	appear.tween_property(button, "modulate:a", 1.0, 0.2)


func _on_next_pressed() -> void:
	button.disabled = true
	$UI_Click.post_event()
	Wwise.post_event("Stop_Intro_BG", $Intro_Music)
	await get_tree().create_timer(1.0).timeout 
	GameManager.start_next_night()
	GameManager.fade_from_black = true
	GameManager.set_state(GameManager.GameState.PLAYING)
	SceneManager.change_scene(MAIN_SCENE)

func _process(_delta: float) -> void:
	var count := report.visible_characters
	if count <= _last_count:
		return
	var text := report.text
	var typed := false
	var coin := false
	var total := false
	for i in range(_last_count, count):
		var letter := text[i]
		if letter == "$":
			_in_money = true
		var next := text[i + 1] if i + 1 < text.length() else "\n"
		if _in_money and next == "\n":
			coin = true
			_in_money = false
			if i == text.length() - 1:
				total = true
		if letter != " " and letter != "\n":
			typed = true
	if typed:
		$UI_Typing.post_event()
	if total:
		$Cash_Register.post_event()
	elif coin:
		$Coin.post_event()
	_last_count = count
