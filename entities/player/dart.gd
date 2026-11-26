extends Area2D

@export var speed: int = 100

var direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction
	if direction != Vector2.ZERO:
		# The dart sprite points up at zero rotation.
		global_rotation = direction.angle() + PI / 2.0



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"Enemy"):
		body.try_sleep_from_dart()
		
	self.queue_free()


