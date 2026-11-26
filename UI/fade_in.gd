extends CanvasLayer

var _blocking := false


func _ready() -> void:
	if not GameManager.fade_from_black:
		visible = false
		queue_free()
		return
	GameManager.fade_from_black = false
	_blocking = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	var cover := $Cover as ColorRect
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cover.modulate.a = 1.0
	get_tree().paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.2)
	tween.tween_property(cover, "modulate:a", 0.0, 1.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_reveal)


func _input(_event: InputEvent) -> void:
	if _blocking:
		get_viewport().set_input_as_handled()


func _reveal() -> void:
	_blocking = false
	get_tree().paused = false
	queue_free()
