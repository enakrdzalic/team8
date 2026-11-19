extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play(&"enemy_idle")

func physicsUpdate(_delta: float) -> void:
	if enemy.health <= 0:
		Transitioned.emit(self, "EnemyDie")
		return

	Transitioned.emit(self, "EnemyPatrol")
