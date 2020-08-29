extends Node2D

func _ready():
	pass

func set_value(value, max_value):
	value = clamp(value, 0, max_value)
	$level.rect_size.x = 20.0 * float(value) / float(max_value)
