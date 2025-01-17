extends Control

signal retry
signal quit
signal closed

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func reset():
	$banner.hide()
	$Control.hide()
	pick_random_sfx(get_parent().get_node("sfx/turn_alert"))
	$bg.frame = 0
	$bg.play("default")
	yield(get_tree().create_timer(1.0), "timeout")
	$banner.frame = 0
	$banner.show()
	$banner.play()
	$Control.show()
	$Control/Retry.grab_focus()

func init(_arg):
	reset()
	show()

func out():
	hide()

func _on_Retry_pressed():
	emit_signal("retry")
	emit_signal("closed")

func _on_Quit_pressed():
	emit_signal("quit")
	emit_signal("closed")
