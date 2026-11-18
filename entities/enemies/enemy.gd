extends CharacterBody2D

@export var health : int = 5

func _physics_process(delta: float) -> void:
	if velocity.length() > 0:
		$AnimatedSprite2D.play("enemy_walk")

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		
	move_and_slide()


func take_damage(damage: int) -> void:
	health -= damage
	print("Enemy health: " + str(health))

	if health <= 0:
		$AnimatedSprite2D.play("enemy_die")