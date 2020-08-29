extends Control

var text_color = Color(0.160784, 0.678431, 1)
var selected_color = Color(1, 0.945098, 0.909804)

var selected = 0

signal next
signal retry

var start
var start_x = -64
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
	start_x = -64
	done = false
	
func _process(delta):
	if !visible or done:
		return
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		$positioner.position.x = lerp(start_x, start_x + 64, float(now - start) / float(ttl))
	else:
		done = true
		$positioner.position.x = start_x + 64

func _input(event):
	if !visible:
		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if selected == 0: 
			emit_signal("next")
		else:
			emit_signal("retry")
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		selected += 1
		selected = clamp(selected, 0, 1)
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		selected -= 1
		selected = clamp(selected, 0, 1)
	if selected == 0:
		$next.text = ">NEXT"
		$next.set("custom_colors/font_color", selected_color)
		$retry.text = "RETRY"
		$retry.set("custom_colors/font_color", text_color)
	else:
		$next.text = "NEXT"
		$next.set("custom_colors/font_color", text_color)
		$retry.text = ">RETRY"
		$retry.set("custom_colors/font_color", selected_color)
