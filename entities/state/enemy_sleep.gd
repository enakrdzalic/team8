extends State
class_name EnemySleep

@export var enemy : CharacterBody2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play(&"enemy_die")
	sprite.set_frame_and_progress(sprite.sprite_frames.get_frame_count(&"enemy_die") - 1, 0.0)
	sprite.pause()

func exit() -> void:
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.stop()
