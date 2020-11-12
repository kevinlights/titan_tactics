extends Control

signal confirm_end_turn
signal cancel
signal closed

func _on_end_turn_pressed():
	emit_signal("confirm_end_turn")

func _on_cancel_pressed():
	hide()
	emit_signal("cancel")
	emit_signal("closed")

func init(_arg):
	show()

func out():
	hide()
	emit_signal("closed")
