extends Control

# This is the credits screen shown when all levels have been completed.

func _ready():
	pass # Replace with function body.

func _input(event):
	if !visible:
		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		$select.play()
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().change_scene("res://scenes/landing.tscn")
	if event.is_action("ui_cancel") && !event.is_echo() && event.is_pressed():
		$select.play()
		yield(get_tree().create_timer(0.2), "timeout")
		get_tree().change_scene("res://scenes/landing.tscn")
