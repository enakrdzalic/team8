extends State
class_name EnemyChase

@export var move_speed : float = 50.0
@export var stop_distance: float = 45.0
@export var lose_range: float = 300.0
@export var enemy : CharacterBody2D

var player: CharacterBody2D

func enter():
	player = get_tree().get_first_node_in_group("Player") as CharacterBody2D

func physicsUpdate(delta: float) -> void:
	if not is_instance_valid(enemy):
		return
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	if not is_instance_valid(player):
		enemy.velocity = Vector2.ZERO
		return

	var offset = player.global_position - enemy.global_position
	var distance = offset.length()

	if distance > lose_range:
		enemy.velocity = Vector2.ZERO
		Transitioned.emit(self, "EnemyIdle")
		return

	if distance > stop_distance:
		enemy.velocity = offset.normalized() * move_speed
	else:
		enemy.velocity = Vector2()
		Transitioned.emit(self, "EnemyAttack")
