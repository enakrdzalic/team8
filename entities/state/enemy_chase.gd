extends State
class_name EnemyChase

@export var move_speed : float
@export var stop_distance: float
@export var lose_range: float
@export var enemy : CharacterBody2D

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
		Transitioned.emit(self, "EnemyIdle")
		return

	var offset = player.global_position - enemy.global_position
	var distance = offset.length()

	# if distance > lose_range:
	# 	enemy.velocity = Vector2.ZERO
	# 	Transitioned.emit(self, "EnemyIdle")
	# 	return

	if distance > stop_distance:
		enemy.velocity = offset.normalized() * move_speed
	else:
		enemy.velocity = Vector2()
		Transitioned.emit(self, "EnemyAttack")
