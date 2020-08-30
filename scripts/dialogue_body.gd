extends Label

func _ready():
	var dialogue_height = 6 + 10 * get_visible_line_count()
	get_parent().rect_size.y = dialogue_height
	get_parent().rect_position.y = 144 - dialogue_height

func set_text(body):
	text = body
	call_deferred("_ready")
