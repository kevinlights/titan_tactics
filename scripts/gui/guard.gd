extends Control

signal guard
signal end
signal heal

var text_color = Color(.16, .68, 1)
var selected_color = Color(1, .95, .91)
var unselectable_color = Color(.37, .34, .31)

var guard_button = "GUARD"
var selected = 0
var max_selected = 1
var healer = false

func set_healer(is_healer):
	guard_button = "HEAL" if is_healer else "GUARD"
	healer = is_healer
	$guard.text = ">" + guard_button

func _input(event):
	if !visible:
		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if selected == 0:
			if(healer):
				emit_signal("heal")
			else:
				emit_signal("guard")
		else:
			emit_signal("end")
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		selected += 1
		selected = clamp(selected, 0, max_selected)
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		selected -= 1
		selected = clamp(selected, 0, max_selected)
	if selected == 0:
		$guard.text = ">" + guard_button
		$guard.set("custom_colors/font_color", selected_color)
		$end.text = " END"
		$end.set("custom_colors/font_color", text_color)
	else:
		$guard.text = " " + guard_button
		$guard.set("custom_colors/font_color", text_color)
		$end.text = ">END"
		$end.set("custom_colors/font_color", selected_color)		
