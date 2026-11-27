extends CharacterBody2D

const ZoneCamera = preload("res://maps/zone_camera.gd")

@export var SPEED = 300.0
@export var weapon_damage : int = 1
@export var health: int = 5
@export var move_factor: float = 2
@export var camera_zoom_factor: float = 2
@export var Dart: PackedScene
@export var dart_count : int = 3

var last_direction := Vector2.RIGHT
var is_attacking: bool = false
var is_dragging: bool = false
var is_shooting: bool = false
var hitbox_offset : Vector2
var dragged_body: Node2D = null
var dragged_body_parent: Node = null
var drag_axis := Vector2.ZERO

@onready var zone_camera := get_node_or_null("../ZoneCamera") as ZoneCamera
@onready var zone_camera_zoom = zone_camera.zoom
# var enemy : CharacterBody2D


func _ready() -> void:
	hitbox_offset = $AttackHitbox.position

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	if is_instance_valid(dragged_body) and not dragged_body.can_be_dragged():
		is_dragging = false
		release()

	if Input.is_action_pressed("drag") and not is_attacking:
		drag()
	else:
		is_dragging = false
		release()
	
	if Input.is_action_just_pressed("shoot") and not is_attacking and not is_dragging:
		if dart_count > 0:
			shoot()
			dart_count -= 1
		else:
			print("out of the dart!!")
		


	if is_attacking or is_shooting:
		velocity = Vector2.ZERO
		return

	process_movement()
	process_animation()
	move_and_slide()

## Handling Movement ##

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if is_instance_valid(dragged_body):
		direction = (direction * drag_axis).normalized()
	
	if direction != Vector2.ZERO:
		last_direction = direction
		if is_dragging:
			velocity = direction * (SPEED / move_factor)
		else:
			velocity = direction * SPEED
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO

func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)
	
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0:
		$AnimatedSprite2D.play(prefix + "_right")
	elif dir.x < 0:
		$AnimatedSprite2D.play(prefix + "_left")
	elif dir.y > 0:
		$AnimatedSprite2D.play(prefix + "_down")
	elif dir.y < 0:
		$AnimatedSprite2D.play(prefix + "_up")
	else:
		$AnimatedSprite2D.stop()

## Handling Attacking ##

func attack() -> void:
	is_attacking = true
	$AttackHitbox/CollisionShape2D.set_deferred("disabled", false)
	play_animation("attack", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		$AttackHitbox/CollisionShape2D.set_deferred("disabled", true)
	
func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y

	match last_direction:
		Vector2.LEFT:
			$AttackHitbox.position = Vector2(-x, y)
			$DragHitbox.position = Vector2(-x, y)
			$DartPoint.position = Vector2(-x, y)
		Vector2.RIGHT:
			$AttackHitbox.position = Vector2(x, y)
			$DragHitbox.position = Vector2(x, y)
			$DartPoint.position = Vector2(x, y)
		Vector2.UP:
			$AttackHitbox.position = Vector2(y, -x)
			$DragHitbox.position = Vector2(y, -x)
			$DartPoint.position = Vector2(y, -x)
		Vector2.DOWN:
			$AttackHitbox.position = Vector2(-y, x)
			$DragHitbox.position = Vector2(-y, x)
			$DartPoint.position = Vector2(-y, x)


## Handling Drag ##

func drag() -> void:
	is_dragging = true
	$DragHitbox/CollisionShape2D.set_deferred("disabled", false)
	# play_animation("drag", last_direction)

func release() -> void:
	$DragHitbox/CollisionShape2D.set_deferred("disabled", true)
	if is_instance_valid(dragged_body):
		if not is_instance_valid(dragged_body_parent):
			dragged_body_parent = get_tree().current_scene
		dragged_body.reparent(dragged_body_parent, true)
		if dragged_body is PhysicsBody2D:
			remove_collision_exception_with(dragged_body)
			dragged_body.remove_collision_exception_with(self)
	dragged_body = null
	dragged_body_parent = null
	drag_axis = Vector2.ZERO

	if !is_dragging and zone_camera.zoom == zone_camera_zoom * camera_zoom_factor:
		var tween := create_tween()
		tween.tween_property(zone_camera, "zoom", zone_camera_zoom, 0.1)

	# play_animation("release", last_direction)

func _on_drag_hitbox_body_entered(body: Node2D) -> void:
	if not is_dragging or is_instance_valid(dragged_body) or body == self:
		return
	if body.is_ancestor_of(self) or is_ancestor_of(body):
		return
	if not body.is_in_group(&"Enemy"):
		return

	_drag_body.call_deferred(body)


func _drag_body(body: Node2D) -> void:
	if not is_dragging or is_instance_valid(dragged_body) or not is_instance_valid(body):
		return
	if not body.has_method(&"can_be_dragged") or not body.can_be_dragged():
		return

	var tween := create_tween()
	tween.tween_property(zone_camera, "zoom", zone_camera_zoom * camera_zoom_factor, 0.1)

	dragged_body = body
	dragged_body_parent = body.get_parent()
	var offset := body.global_position - global_position
	drag_axis = Vector2.RIGHT if absf(offset.x) >= absf(offset.y) else Vector2.DOWN
	if body is PhysicsBody2D:
		add_collision_exception_with(body)
		body.add_collision_exception_with(self)
	body.reparent(self, true)
	print(body.name + " dragged")


## Handling Damage ## 

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.is_in_group("Enemy"):
		print(body.name + " hit")
		body.take_damage(weapon_damage)

func take_damage(damage: int) -> void:
	# health = maxi(0, health - damage)
	print("hitted")


## Handling Shooting ##

func shoot() -> void:
	var dart_instance = Dart.instantiate()
	get_tree().current_scene.add_child(dart_instance)
	dart_instance.global_position = $DartPoint.global_position
	dart_instance.set_direction(last_direction)
