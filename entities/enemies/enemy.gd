extends CharacterBody2D

const ZoneCamera = preload("res://maps/zone_camera.gd")

@export var health : int = 5

var is_dead := false
var home_zone := -1

@onready var zone_camera := get_node_or_null("../ZoneCamera") as ZoneCamera

func _ready() -> void:
	if zone_camera != null:
		home_zone = zone_camera.zone_containing(global_position)

func can_target_player(player: Node2D) -> bool:
	if not is_instance_valid(player):
		return false
	if home_zone == -1 or not is_instance_valid(zone_camera):
		return true
	return zone_camera.zone_containing(player.global_position, zone_camera.current_zone) == home_zone

func mark_dead() -> void:
	is_dead = true
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_dead:
		return

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
