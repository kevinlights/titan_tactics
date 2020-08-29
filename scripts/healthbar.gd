extends Node2D

func _ready():
	pass

func set_value(value, max_value):
	if value < max_value:
		$level.rect_size.x = 14.0 * float(value) / float(max_value)
	else:
		$level.rect_size.x = 14.0

