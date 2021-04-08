extends Control

signal closed
signal ok

var start = 0
var ttl = 6500

#func display(description):
#	start = OS.get_ticks_msec()
#	$margin/description.text = description
#	show()

func init(arg):
	$roll/AnimationPlayer.current_animation = "roll"
	$roll/ok.grab_focus()
	show()

func out():
	hide()

#func _input(event):
#	if !visible:
#		return
#	if (event.is_action("ui_accept") or event.is_action("ui_select")) && !event.is_echo() && event.is_pressed():
#		call_deferred("hide")
#		emit_signal("closed")

#func _process(_delta):
#	if !visible:
#		return
#	var now = OS.get_ticks_msec()
#	if now - start > ttl:
#		emit_signal("closed")
#		hide()


func _on_close_credits():
	pass # Replace with function body.


func _on_ok_pressed():
	emit_signal("ok")
