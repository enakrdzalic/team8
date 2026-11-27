extends CanvasLayer

# Placeholder controls for the core loop. Later these get replaced by real
# kills and drags; the money rules live in GameManager.

const UIStyle = preload("res://UI/ui_style.gd")

const RESULTS_SCENE := "res://UI/results.tscn"
const FADE_SECONDS := 0.9

@onready var kill_button: Button = $KillButton
@onready var drag_button: Button = $DragButton
@onready var end_button: Button = $EndNightButton
@onready var kill_count: Label = $KillCount
@onready var drag_count: Label = $DragCount
@onready var fade: ColorRect = $Fade

var _ending := false


func _ready() -> void:
	for target: Button in [kill_button, drag_button, end_button]:
		UIStyle.style_button(target)
		# Keep Space (drag) and Enter from also pressing these.
		target.focus_mode = Control.FOCUS_NONE
	for counter: Label in [kill_count, drag_count]:
		_style_counter(counter)
	kill_button.pressed.connect(_on_kill_pressed)
	drag_button.pressed.connect(_on_drag_pressed)
	end_button.pressed.connect(_on_end_night_pressed)
	_refresh_counts()


func _on_kill_pressed() -> void:
	if _ending:
		return
	GameManager.record_kill()
	_refresh_counts()


func _on_drag_pressed() -> void:
	if _ending:
		return
	GameManager.record_drag()
	_refresh_counts()


func _refresh_counts() -> void:
	kill_count.text = str(GameManager.monsters_killed)
	drag_count.text = str(GameManager.monsters_dragged)


# Outlined so the numbers stay readable over the city art.
func _style_counter(target: Label) -> void:
	target.add_theme_font_size_override("font_size", 28)
	target.add_theme_color_override("font_color", UIStyle.CREAM)
	target.add_theme_color_override("font_outline_color", Color.BLACK)
	target.add_theme_constant_override("outline_size", 6)


func _on_end_night_pressed() -> void:
	if _ending:
		return
	_ending = true
	# The fade also swallows clicks while the screen goes dark.
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, FADE_SECONDS)
	tween.tween_callback(_show_results)


func _show_results() -> void:
	GameManager.finish_night()
	SceneManager.change_scene(RESULTS_SCENE)
