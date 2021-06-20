extends Control
signal ok
signal closed

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func init(_arg):
	show()
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
	$Control/Ok.grab_focus()

func out():
	hide()

func _on_Ok_pressed():
	emit_signal("ok")
	emit_signal("closed")
