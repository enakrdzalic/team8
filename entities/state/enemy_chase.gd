extends State
class_name EnemyChase

@export var move_speed : float
@export var stop_distance: float
@export var lose_range: float
@export var enemy : CharacterBody2D
@export var music_range: float = 400.0
var player: CharacterBody2D


func enter():
	player = get_tree().get_first_node_in_group("Player") as CharacterBody2D

func physicsUpdate(delta: float) -> void:
	if enemy.health <= 0:
		Transitioned.emit(self, "EnemyDie")
		return
	
	if not is_instance_valid(enemy):
		return
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	if not enemy.can_pursue_player(player):
		enemy.velocity = Vector2.ZERO
		leave_combat()
		Transitioned.emit(self, "EnemyIdle")
		return

	var offset = player.global_position - enemy.global_position
	var distance = offset.length()
	if distance > music_range:
		leave_combat()
	elif distance < music_range * 0.75:
		join_combat()

	# if distance > lose_range:
	# 	enemy.velocity = Vector2.ZERO
	# 	Transitioned.emit(self, "EnemyIdle")
	# 	return

	if distance > stop_distance:
		enemy.velocity = offset.normalized() * move_speed
	else:
		enemy.velocity = Vector2()
		Transitioned.emit(self, "EnemyAttack")
	
func join_combat():
	var music = get_tree().current_scene.get_node("Combat_Music")
	if not enemy.get_meta("in_combat", false):
		enemy.set_meta("in_combat", true)
		var count = music.get_meta("fighters", 0) + 1
		music.set_meta("fighters", count)
		if count == 1:
			music.post_event()

func leave_combat():
	var music = get_tree().current_scene.get_node("Combat_Music")
	if enemy.get_meta("in_combat", false):
		enemy.set_meta("in_combat", false)
		var count = music.get_meta("fighters", 0) - 1
		music.set_meta("fighters", max(count, 0))
		if count <= 0:
			Wwise.post_event("Stop_Combat_Music", music)
