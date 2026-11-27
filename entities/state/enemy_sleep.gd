extends State
class_name EnemySleep

@export var enemy : CharacterBody2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play(&"enemy_die")
	sprite.set_frame_and_progress(sprite.sprite_frames.get_frame_count(&"enemy_die") - 1, 0.0)
	sprite.pause()
	enemy.get_node("Monster_Sleep").post_event()
	var music = get_tree().current_scene.get_node("Combat_Music")
	if enemy.get_meta("in_combat", false):
		enemy.set_meta("in_combat", false)
		var count = music.get_meta("fighters", 0) - 1
		music.set_meta("fighters", max(count, 0))
		if count <= 0:
			Wwise.post_event("Stop_Combat_Music", music)

func exit() -> void:
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.stop()
	enemy.get_node("Monster_Sleep").post_event()
