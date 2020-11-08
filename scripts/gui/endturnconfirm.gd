extends Control

signal confirm_end_turn
signal cancel

func _on_end_turn_pressed():
	emit_signal("confirm_end_turn")

func _on_cancel_pressed():
	hide()
	emit_signal("cancel")

func init(_arg):
	show()

func out():
	hide()
