extends Node
class_name State

signal Transitioned

# On transition to this state
func enter() -> void:
	pass

# When leaving this state
func exit() -> void:
	pass

# Every frame while active
func update(delta: float) -> void:
	pass

# Every physics tick while active
func physicsUpdate(delta: float) -> void:
	pass