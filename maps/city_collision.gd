extends Node2D

# Building, water, and the empty border around the city. Streets stay open,
# including where a zone line crosses them.


func _ready() -> void:
	var file := FileAccess.open("res://maps/city_blocks.bin", FileAccess.READ)
	if file == null:
		return
	var count := file.get_16()
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)
	for _i in count:
		var x := float(file.get_16())
		var y := float(file.get_16())
		var block_width := float(file.get_16())
		var block_height := float(file.get_16())
		var shape := RectangleShape2D.new()
		shape.size = Vector2(block_width, block_height)
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = Vector2(x, y) + shape.size * 0.5
		body.add_child(collision)
