extends Node2D

var start
var ttl
var ms_per_pixel = 100

func _ready():
	start = OS.get_ticks_msec()
	ttl = $panel/text.rect_size.y * ms_per_pixel
	$scroll_theme.play()

func _process(delta):
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		$panel/text.rect_position.y = lerp(144, -1 * ($panel/text.rect_size.y - 120), float(now - start) / float(ttl))

func _input(event):
	var now = OS.get_ticks_msec()
	if event.is_action("ui_down") && event.is_pressed():
		start -= 600
	if event.is_action("ui_up") && event.is_pressed():
		start += 600
		if now - start > ttl:
			start = now - ttl + 600
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://scenes/world.tscn")
