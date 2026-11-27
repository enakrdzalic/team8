extends State
class_name EnemyPatrol

@export var patrol_speed: float = 60.0
@export var wait_time: float = 1.5
@export var arrival_distance: float = 5.0

@export var point_a: Marker2D
@export var point_b: Marker2D

@export var enemy : CharacterBody2D
var player: CharacterBody2D

@export var sight: Area2D

@onready var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D

var target_position: Vector2
var waiting: bool = false
var wait_timer: float = 1.0

func enter() -> void:
	target_position = point_a.global_position
	waiting = false
	player = get_tree().get_first_node_in_group(&"Player") as CharacterBody2D

func physicsUpdate(delta: float) -> void:
	if enemy.health <= 0:
		Transitioned.emit(self, "EnemyDie")
		return
	
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group(&"Player") as CharacterBody2D

	if enemy.has_player_left_home_zone(player):
		Transitioned.emit(self, "EnemyIdle")
		return

	for body in sight.get_overlapping_bodies():
		if body.is_in_group(&"Player") and enemy.can_target_player(body):
			Transitioned.emit(self, "EnemyChase")
			return
		
	if waiting:
		enemy.velocity = Vector2.ZERO

		wait_timer -= delta

		if wait_timer <= 0:
			waiting = false
	
		enemy.move_and_slide()
		return
	
	var direction = enemy.global_position.direction_to(target_position)

	update_sight_offset(direction)
	enemy.velocity = direction * patrol_speed
	enemy.move_and_slide()

	if enemy.global_position.distance_to(target_position) <= arrival_distance: 
		reach_patrol_point()

func reach_patrol_point() -> void:
	enemy.velocity = Vector2.ZERO
	waiting = true
	wait_timer = wait_time
	
	sprite.play("enemy_idle")

	# Switch to the other patrol point
	if target_position == point_a.global_position:
		target_position = point_b.global_position
	else:
		target_position = point_a.global_position

func update_sight_offset(direction: Vector2) -> void:
	if sight == null or direction.is_zero_approx():
		return

	var angle := fposmod(direction.angle(), TAU)
	sight.position = sight.position.rotated(angle - sight.rotation)
	sight.rotation = angle
