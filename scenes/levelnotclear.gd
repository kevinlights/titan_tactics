extends Control

signal retry
signal quit

var start
var start_x = -160
var ttl = 500
var done = true

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func _ready():
	pass

func reset():
	pick_random_sfx(get_parent().get_node("sfx/turn_alert"))
	start = OS.get_ticks_msec()
	start_x = -160
	done = false
	
func _process(delta):
	if !visible or done:
		return
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		$positioner2.position.x = lerp(start_x, start_x + 160, float(now - start) / float(ttl))
		$Control.rect_global_position.x = lerp(60, 0, float(now - start) / float(ttl))
	else:
		done = true
		$Control.rect_global_position.x = 0
		$positioner2.position.x = start_x + 160



func _on_Retry_pressed():
	emit_signal("retry")


func _on_Quit_pressed():
	emit_signal("quit")
