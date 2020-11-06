extends Control

signal done

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func init(_arg):
	pick_random_sfx(get_parent().get_node("sfx/turn_alert"))
	$banner.frame = 0
	show()
	$banner.play()
	yield(get_tree().create_timer(4.0), "timeout")
	get_parent().back()
	emit_signal("done")

func out():
	hide()
