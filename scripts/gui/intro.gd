extends Control

signal closed

var start = 0
var ttl = 6500

func display(description):
	start = OS.get_ticks_msec()
	$margin/description.text = description
	show()

func _input(event):
	if !visible:
		return
	if (event.is_action("ui_accept") or event.is_action("ui_select")) && !event.is_echo() && event.is_pressed():
		call_deferred("hide")
		emit_signal("closed")

func _process(delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	if now - start > ttl:
		emit_signal("closed")
		hide()
