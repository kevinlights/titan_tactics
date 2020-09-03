extends Control

signal done

var start
var start_x = -160
var ttl = 60
var done = true

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func _ready():
	pass

func reset():
	print("next turn ui reset")
	pick_random_sfx(get_parent().get_node("sfx/turn_alert"))
	start = OS.get_ticks_msec()
	start_x = -160
	done = false
	
func _process(delta):
	if !visible or done:
		return
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		$positioner.position.x = lerp(start_x, start_x + 160, float(now - start) / float(ttl))
	else:
		done = true
		$positioner.position.x = start_x + 160
		yield(get_tree().create_timer(2.0), "timeout")
		$positioner.position.x = -160
		hide()
		emit_signal("done")
