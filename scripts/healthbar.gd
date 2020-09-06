extends Node2D

func _ready():
	pass

func set_value(value, max_value):
	if max_value == 0:
		print("Max HP for this character is 0, please fix")
		max_value = 1
	if value < max_value:
		$level.rect_size.x = 14.0 * float(value) / float(max_value)
	else:
		$level.rect_size.x = 14.0

