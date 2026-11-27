extends CharacterBody2D

const ZoneCamera = preload("res://maps/zone_camera.gd")

@export var health : int = 5

var is_dead := false
var home_zone := -1
var pursuit_zone := -1

@onready var zone_camera := get_node_or_null("../ZoneCamera") as ZoneCamera
@onready var state_machine := $StateMachine

func _ready() -> void:
	if zone_camera != null:
		home_zone = zone_camera.zone_containing(global_position)

func can_target_player(player: Node2D) -> bool:
	return is_player_in_zone(player, home_zone)

func can_pursue_player(player: Node2D) -> bool:
	var target_zone := pursuit_zone if pursuit_zone != -1 else home_zone
	return is_player_in_zone(player, target_zone)

func is_player_in_zone(player: Node2D, zone: int) -> bool:
	if not is_instance_valid(player):
		return false
	if zone == -1 or not is_instance_valid(zone_camera):
		return true
	return zone_camera.zone_containing(player.global_position, zone_camera.current_zone) == zone

func has_player_left_home_zone(player: Node2D) -> bool:
	if not is_instance_valid(player) or not is_instance_valid(zone_camera):
		return false
	if home_zone == -1:
		return false
	return not can_target_player(player)

func mark_dead() -> void:
	is_dead = true
	pursuit_zone = -1
	velocity = Vector2.ZERO

func can_be_dragged() -> bool:
	return is_dead or state_machine.current_state is EnemySleep

func get_zone_away_from_home() -> int:
	if home_zone == -1 or not is_instance_valid(zone_camera):
		return -1
	var zone := zone_camera.zone_containing(global_position)
	if zone == home_zone:
		return -1
	return zone

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
	if health > 0:
		health -= damage
		print("Enemy health: " + str(health))
		$HitFlashAnime.play("hit")
	else:
		print("dead!!")

	var state = state_machine.current_state
	if state is EnemySleep:
		if health <= 0:
			state.Transitioned.emit(state, "EnemyDie")
		else:
			pursuit_zone = get_zone_away_from_home()
			state.Transitioned.emit(state, "EnemyChase")

func try_sleep_from_dart() -> void:
	var state = state_machine.current_state
	if health > 0 and state is EnemyPatrol:
		state.Transitioned.emit(state, "EnemySleep")
