extends State
class_name EnemyIdle

const ARRIVAL_DISTANCE := 1.0

@export var move_speed: float = 200.0

@export var enemy: CharacterBody2D
@export var spawn_point: Marker2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	if enemy.pursuit_zone != -1:
		enemy.pursuit_zone = -1
		if is_instance_valid(spawn_point):
			enemy.global_position = spawn_point.global_position
			enemy.reset_physics_interpolation()
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play(&"enemy_idle")

func physicsUpdate(delta: float) -> void:
	if enemy.health <= 0:
		Transitioned.emit(self, "EnemyDie")
		return

	if is_instance_valid(spawn_point):
		var offset := spawn_point.global_position - enemy.global_position
		if offset.length_squared() > ARRIVAL_DISTANCE * ARRIVAL_DISTANCE:
			# Enemy applies velocity in its own physics callback.
			enemy.velocity = (offset / delta).limit_length(move_speed)
			return

	if not enemy.velocity.is_zero_approx():
		enemy.velocity = Vector2.ZERO
		var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
		sprite.play(&"enemy_idle")

	var player := get_tree().get_first_node_in_group(&"Player") as Node2D
	if enemy.can_target_player(player):
		Transitioned.emit(self, "EnemyPatrol")
