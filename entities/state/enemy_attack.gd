extends State
class_name EnemyAttack

@export var enemy : CharacterBody2D
@export var attack_damage: int = 1

var player: CharacterBody2D
var hit_player_this_swing := false
@onready var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
@onready var hitbox := enemy.get_node_or_null("AttackHitbox") as Area2D

func enter():
	player = get_tree().get_first_node_in_group("Player") as CharacterBody2D

func physicsUpdate(_delta: float) -> void:
	if not is_instance_valid(enemy):
		return

	enemy.velocity = Vector2.ZERO
	if sprite.animation == &"enemy_attack" and sprite.is_playing():
		try_damage_player()
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
	if not is_instance_valid(player):
		return

	var offset = player.global_position - enemy.global_position
	var distance = offset.length()

	if distance <= 45.0:
		if not is_zero_approx(offset.x):
			sprite.flip_h = offset.x < 0.0
		update_hitbox_offset(enemy.to_local(player.global_position))
		attack()
		sprite.set_frame_and_progress(0, 0.0)
	else:
		Transitioned.emit(self, "EnemyChase")

func update_hitbox_offset(direction: Vector2) -> void:
	if hitbox == null or direction.is_zero_approx():
		return

	var angle := snappedf(direction.angle(), PI / 2.0)
	hitbox.position = hitbox.position.rotated(angle - hitbox.rotation)
	hitbox.rotation = angle

func attack() -> void:
	hit_player_this_swing = false
	sprite.play(&"enemy_attack")

func try_damage_player() -> void:
	if hit_player_this_swing or hitbox == null or not is_instance_valid(player):
		return

	# The fourth through sixth animation frames have indices 3 through 5.
	if sprite.frame < 4 or sprite.frame > 6:
		return

	if hitbox.overlaps_body(player):
		hit_player_this_swing = true
		player.take_damage(attack_damage)
