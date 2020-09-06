extends Control

signal swap
signal dont_swap

var text_color = Color(0.219608, 0.596078, 0.454902)
var selected_color = Color(0.917647, 1, 0.866667)

var selected = 0

var current_gear
var new_gear
var gear_type

var current_stat
var new_stat

var atlas = {
	Game.TYPE.OTHER: 17,
	Game.TYPE.FIGHTER: 32,
	Game.TYPE.ARCHER: 33,
	Game.TYPE.MAGE: 34
}

func _ready():
	pass

func set_weapons(current, new, type):
	#i'm getting type varible to control if item is atk or def
	current_gear = current
	new_gear = new
	gear_type = type
	print(current_gear.name)
	print(current_gear.attack)
	print(new_gear.name)
	print(new_gear.attack)
	$text.text = new_gear.name
	if type == Item.SLOT.ATK:
		$item_popup.region_rect.position.y = 67
	else:
		$item_popup.region_rect.position.y = 0

func _process(delta):
	if visible == false:
		return
	current_stat = 1
	new_stat = 2
	#based on what type the gear is i assign values in text
	if gear_type == Item.SLOT.ATK:
		$current_stat.text = str("+", int(round(current_gear.attack)))
		$new_stat.text = str("+", int(round(new_gear.attack)))
	else:
		$current_stat.text = str("+", int(round(current_gear.defense)))
		$new_stat.text = str("+", int(round(new_gear.defense)))
	$weapon_sprite1.frame = atlas[current_gear.character_class]
	$weapon_sprite2.frame = atlas[new_gear.character_class]
	if gear_type == Item.SLOT.DEF:
		$weapon_sprite1.frame = atlas[Game.TYPE.OTHER]
		$weapon_sprite2.frame = atlas[Game.TYPE.OTHER]
	if selected == 0:
		$no/focus.show()
		$yes/focus.hide()
		$yes.set("custom_colors/font_color", selected_color)
		$no.set("custom_colors/font_color", text_color)
	if selected == 1:
		$yes/focus.show()
		$no/focus.hide()
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
			emit_signal("swap", new_gear)
		elif selected == 1:
			emit_signal("dont_swap")
