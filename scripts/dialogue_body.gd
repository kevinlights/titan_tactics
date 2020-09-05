extends Label

#var content
#
#func _ready():
#	var dialogue_height = 10 + 10 * get_visible_line_count()
#	get_parent().rect_size.y = dialogue_height
#	get_parent().rect_position.y = 144 - dialogue_height
#
#func set_text(body):
#	text = body.text
#	content = body
#	call_deferred("_ready")
#
#func _input(event):
#	if not get_parent().get_parent().visible:
#		return
#	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
#		content.complete()
##		gui.team_confirm()
