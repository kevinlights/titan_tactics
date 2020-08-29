extends Control

var start = 0
var start_y = 0
var ttl = 400
var delay = 1000
var display_start = 0

func _ready():
	pass
#	notify("Test message")

func notify(message):
	display_start = OS.get_ticks_msec()
	start_y = 56
	$message.rect_position.y = start_y
	$message.text = message
	$message.set("modulate", Color(1, 1, 1, 1))
	print(message)
	show()

func start_fade():
	start = OS.get_ticks_msec()
	
func _process(delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	if now - display_start < delay:
		return
	else:
		if start == 0:
			start_fade()
	if now - start < ttl:
		$message.rect_position.y = lerp(start_y, start_y + 10, float(now - start) / float(ttl))
		var modulate = Color(1, 1, 1, lerp(1, 0, float(now - start) / float(ttl)))
		$message.set("modulate", modulate)
	else:
		start = 0
		hide()
