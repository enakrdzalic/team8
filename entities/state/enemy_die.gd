extends State
class_name EnemyDie

signal enemy_dead

@export var enemy : CharacterBody2D

var player: CharacterBody2D

func enter() -> void:
	print("dead")
	enemy.mark_dead()
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play(&"enemy_die")
	enemy_dead.emit()
	enemy.get_node("Monster_Dying").post_event() 
	var music = get_tree().current_scene.get_node("Combat_Music")
	if enemy.get_meta("in_combat", false):
		enemy.set_meta("in_combat", false)
		var count = music.get_meta("fighters", 0) - 1
		music.set_meta("fighters", max(count, 0))
		if count <= 0:
			Wwise.post_event("Stop_Combat_Music", music)
