extends Control

signal confirm_skip
signal cancel
signal closed

func _on_end_turn_pressed():
	emit_signal("confirm_skip")

func _on_cancel_pressed():
	hide()
	emit_signal("cancel")
	emit_signal("closed")

func init(_arg):
	show()

func out():
	hide()
	emit_signal("closed")

func _input(event):
	if !self.visible:
		return
	if (event.is_action("ui_up") || event.is_action("ui_down")) && !event.is_echo() && event.is_pressed():
		$panel/end_turn/focus.visible = not $panel/end_turn/focus.visible
		$panel/cancel/focus.visible = not $panel/end_turn/focus.visible
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if $panel/end_turn/focus.visible:
			hide()
			emit_signal("confirm_skip")
		else:
			hide()
			emit_signal("cancel")
