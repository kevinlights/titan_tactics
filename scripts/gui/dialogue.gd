extends Control

var content

func _ready():
	var dialogue_height = 6 + 10 * $background/body.get_visible_line_count()
	$background.rect_size.y = dialogue_height
	$background.rect_position.y = 144 - dialogue_height

func set_text(body):
	$background/body.text = body.text
	content = body
	call_deferred("_ready")

func _input(event):
	if not visible:
		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		content.complete()
