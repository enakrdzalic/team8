extends State
class_name EnemyDie

# signal enemy_dead

@export var enemy : CharacterBody2D

var player: CharacterBody2D

func enter() -> void:
    enemy.mark_dead()
    var sprite := enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
    sprite.play(&"enemy_die")
    # enemy_dead.emit()
