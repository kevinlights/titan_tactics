extends Control

signal done

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func reset():
	pick_random_sfx(get_parent().get_node("sfx/turn_alert"))
	$banner.frame = 0
	$banner.play()
	yield(get_tree().create_timer(4.0), "timeout")
	hide()
	emit_signal("done")
