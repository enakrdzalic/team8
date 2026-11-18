extends State
class_name EnemyIdle

@export var wander_speed : float = 50.0
@export var detection_range: float = 200.0
@export var enemy : CharacterBody2D

var player: CharacterBody2D

var move_direcrtion: Vector2
var wander_time : float

func randomize_wander() -> void:
	wander_time = randf_range(1.0, 3.0)
	move_direcrtion = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	randomize_wander()

func update(delta: float) -> void:
	if wander_time > 0.0:
		wander_time -= delta
	else:
		randomize_wander()

func physicsUpdate(delta: float) -> void:
	if enemy:
		enemy.velocity = move_direcrtion * wander_speed

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	if not is_instance_valid(player) or not is_instance_valid(enemy):
		return

	var distance = player.global_position.distance_to(enemy.global_position)

	if distance < detection_range:
		Transitioned.emit(self, "EnemyChase")
