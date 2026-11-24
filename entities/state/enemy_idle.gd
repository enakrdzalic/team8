extends State
class_name EnemyIdle

const ARRIVAL_DISTANCE := 1.0

@export var move_speed: float = 200.0

@export var enemy: CharacterBody2D
@export var spawn_point: Marker2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play(&"enemy_idle")

func physicsUpdate(delta: float) -> void:
	if enemy.health <= 0:
		Transitioned.emit(self, "EnemyDie")
		return

	if not is_instance_valid(spawn_point):
		Transitioned.emit(self, "EnemyPatrol")
		return

	var offset := spawn_point.global_position - enemy.global_position
	if offset.length_squared() <= ARRIVAL_DISTANCE * ARRIVAL_DISTANCE:
		enemy.velocity = Vector2.ZERO
		Transitioned.emit(self, "EnemyPatrol")
		return

	# Enemy applies velocity in its own physics callback.
	enemy.velocity = (offset / delta).limit_length(move_speed)
