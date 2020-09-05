extends Control

var text_color = Color(.64, .53, .47)
var selected_color = Color(1, .95, .91)
onready var menu = get_node("Control").get_children()
var selected = 0

signal close

var player_data 
var file = File.new()
var save_path = "user://save.dat"

var sfx
var music
var input_type

onready var music_bars = get_node("musicBars").get_children()
onready var sfx_bars = get_node("musicBars").get_children()

func _save():
	file.open(save_path, File.WRITE)
	file.store_var(player_data)
	file.close()
func _load():
	file.open(save_path, File.READ)
	player_data = file.get_var()
	file.close()
func _ready():
	return
	# _load()
	# music = player_data.music
	# sfx = player_data.sfx
	# input_type = player_data.input_type
	# select_menu_item(0)

func action(name):
	if name == "music":
		player_data.music += 1
	if name == "SFX":
		player_data.sfx += 1
	if name == "Save":
		_save()
		emit_signal("close")
		visible = false
	if name == "Cancel":
		emit_signal("close")
		visible = false

func select_menu_item(item):
	menu[selected].set("custom_colors/font_color", text_color)
	selected = clamp(item, 0, menu.size() - 1)
	menu[selected].set("custom_colors/font_color", selected_color)

func _input(event):
	if !visible:
		return
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		if selected < 2:
			select_menu_item(selected + 1)
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		if selected < 2:
			select_menu_item(selected - 1)
		else:
			select_menu_item(1)
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		action(menu[selected].name)
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
		if selected > 1:
			select_menu_item(selected - 1)
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
		if selected > 1:
			select_menu_item(selected + 1)

func _process(delta):
	return
	if player_data.music > 5:
		player_data.music = 1
	if player_data.music == 5:
		get_node("musicBars/bar1").frame = 168
		get_node("musicBars/bar2").frame = 169
		get_node("musicBars/bar3").frame = 170
		get_node("musicBars/bar4").frame = 171
		get_node("musicBars/bar5").frame = 172
	elif player_data.music == 4:
		get_node("musicBars/bar1").frame = 168
		get_node("musicBars/bar2").frame = 169
		get_node("musicBars/bar3").frame = 170
		get_node("musicBars/bar4").frame = 171
		get_node("musicBars/bar5").frame = 140
	elif player_data.music == 3:
		get_node("musicBars/bar1").frame = 168
		get_node("musicBars/bar2").frame = 169
		get_node("musicBars/bar3").frame = 170
		get_node("musicBars/bar4").frame = 139
		get_node("musicBars/bar5").frame = 140
	elif player_data.music == 2:
		get_node("musicBars/bar1").frame = 168
		get_node("musicBars/bar2").frame = 169
		get_node("musicBars/bar3").frame = 138
		get_node("musicBars/bar4").frame = 139
		get_node("musicBars/bar5").frame = 140
	elif player_data.music == 1:
		get_node("musicBars/bar1").frame = 168
		get_node("musicBars/bar2").frame = 137
		get_node("musicBars/bar3").frame = 138
		get_node("musicBars/bar4").frame = 139
		get_node("musicBars/bar5").frame = 140
	if player_data.sfx > 5:
		player_data.sfx = 1
	if player_data.sfx == 5:
		get_node("SFXBars/bar1").frame = 168
		get_node("SFXBars/bar2").frame = 169
		get_node("SFXBars/bar3").frame = 170
		get_node("SFXBars/bar4").frame = 171
		get_node("SFXBars/bar5").frame = 172
	elif player_data.sfx == 4:
		get_node("SFXBars/bar1").frame = 168
		get_node("SFXBars/bar2").frame = 169
		get_node("SFXBars/bar3").frame = 170
		get_node("SFXBars/bar4").frame = 171
		get_node("SFXBars/bar5").frame = 140
	elif player_data.sfx == 3:
		get_node("SFXBars/bar1").frame = 168
		get_node("SFXBars/bar2").frame = 169
		get_node("SFXBars/bar3").frame = 170
		get_node("SFXBars/bar4").frame = 139
		get_node("SFXBars/bar5").frame = 140
	elif player_data.sfx == 2:
		get_node("SFXBars/bar1").frame = 168
		get_node("SFXBars/bar2").frame = 169
		get_node("SFXBars/bar3").frame = 138
		get_node("SFXBars/bar4").frame = 139
		get_node("SFXBars/bar5").frame = 140
	elif player_data.sfx == 1:
		get_node("SFXBars/bar1").frame = 168
		get_node("SFXBars/bar2").frame = 137
		get_node("SFXBars/bar3").frame = 138
		get_node("SFXBars/bar4").frame = 139
		get_node("SFXBars/bar5").frame = 140
	if selected == 0:
		get_node("SelectArrow").position.x = 9
		get_node("SelectArrow").position.y = 32
		get_node("SelectArrow").frame = 0
	elif selected == 1:
		get_node("SelectArrow").position.x = 9
		get_node("SelectArrow").position.y = 42
		get_node("SelectArrow").frame = 0
	elif selected == 2:
		get_node("SelectArrow").position.x = 7
		get_node("SelectArrow").position.y = 56
		get_node("SelectArrow").frame = 0
	elif selected == 3:
		get_node("SelectArrow").position.x = 31
		get_node("SelectArrow").position.y = 56
		get_node("SelectArrow").frame = 0

