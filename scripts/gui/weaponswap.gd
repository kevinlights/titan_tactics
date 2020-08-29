extends Control

signal swap
signal dont_swap

var text_color = Color(0.16, 0.68, 1)
var selected_color = Color(1, .95, .91)

var selected = 0

var current_weapon
var new_weapon

var weapon_type
var current_attack
var new_attack

var atlas = {
	Game.TYPE.FIGHTER: 32,
	Game.TYPE.ARCHER: 33,
	Game.TYPE.MAGE: 34
}

func _ready():
	pass

func set_weapons(current, new):
	current_weapon = current
	new_weapon = new
	print(current_weapon.name)
	print(current_weapon.attack)
	print(new_weapon.name)
	print(new_weapon.attack)
	$text.text = new_weapon.name

func _process(delta):
	if visible == false:
		return
	weapon_type = "sword"
	current_attack = 1
	new_attack = 2
	$current_atk.text = str("+", current_weapon.attack)
	$new_atk.text = str("+", new_weapon.attack)
	$weapon_sprite1.frame = atlas[current_weapon.type]
	$weapon_sprite2.frame = atlas[new_weapon.type]
	if selected == 0:
		$yes.text = ">SWITCH"
		$no.text = " CANCEL"
		$yes.set("custom_colors/font_color", selected_color)
		$no.set("custom_colors/font_color", text_color)
	if selected == 1:
		$yes.text = " SWITCH"
		$no.text = ">CANCEL"
		$yes.set("custom_colors/font_color", text_color)
		$no.set("custom_colors/font_color", selected_color)
func _input(event):
	if !visible:
		return
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		selected += 1
		selected = clamp(selected, 0, 1)
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		selected -= 1
		selected = clamp(selected, 0, 1)
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if selected == 0:
			emit_signal("swap", new_weapon)
		elif selected == 1:
			emit_signal("dont_swap")
