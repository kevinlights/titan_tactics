extends Control

signal character_selected
signal library_exhausted
signal closed

var characters = []
var library = []
var selected = 0
var placeholder = load("res://scenes/character_controller.tscn").instance()
onready var select = get_parent().get_parent().get_node("select")

var portraits = {
	TT.TYPE.ARCHER: "archer",
	TT.TYPE.FIGHTER: "swordsman",
	TT.TYPE.MAGE: "mage"
}

func set_spawn(where):
	placeholder.teleport(where.x, where.z - 1)

func init(_arg):
	set_characters(Game.team)
	show()

func out():
	hide()
	emit_signal('closed')

func dismiss():
	emit_signal('closed')

func set_characters(list):
	library = list
	characters = library.duplicate()
	var world = get_tree().get_root().get_node("World")
	var exclude = []
	for character in characters:
		if(world.find_character(character.name)):
			exclude.append(character)
	for character in exclude:
		characters.remove(characters.find(character))
	if not placeholder.get_parent():
		print("Adding placeholder to map")
		get_tree().get_root().get_node("World").add_child(placeholder)
	placeholder.show()
	update_view()

func _ready():
	pass
#	get_tree().get_root().get_node("World").world_map.append_child(placeholder)

func _process(_delta):
	if !visible:
		if placeholder.visible:
			placeholder.hide()
		return
#	if select.animation != "fighter" and select.animation != "mage" and select.animation != "archer":
#		select.play(atlas_frames[characters[selected].character_class])
	$levelline2.set_point_position(1, Vector2(characters[selected].xp/characters[selected].xp_to_next*35, 0))
	$hpline2.set_point_position(1, Vector2(characters[selected].hp/characters[selected].max_hp * 80, 0))
	if characters.size() == 1:
		$Arrows.hide()
	else:
		$Arrows.show()

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()
	
func update_view():
#	var animation = "fighter"
	$name.text = characters[selected].name
	$portraits.show()
	if characters[selected].portrait_override and characters[selected].portrait_override != "":
		$portraits.play(characters[selected].portrait_override)
	elif characters[selected].character_class in portraits:
		$portraits.play(portraits[characters[selected].character_class])
	else:
		$portraits.hide()
#	if $name.text in get_parent().get_node("battle").special_names:
#		$portraits.play($name.text)
#	if !$name.text in get_parent().get_node("battle").special_names:
#
#		$portraits.play("portraits")
#		$portraits.frame = characters[selected].character_class
#		$portraits.playing = false
	
	$atk.text = "%02d" % int(round((characters[selected].atk + characters[selected].item_atk.attack)))
	$hp.text =  "%02d" % int(round(characters[selected].hp))
	$hp.text += "/" + str(characters[selected].max_hp)
	$lvl.text =  "%02d" % characters[selected].level
	$def.text =  "%02d" % int(round((characters[selected].def + characters[selected].item_def.defense)))
	placeholder.from_library(characters[selected])
#	var current = characters[selected]
	
func _input(event):
	if !visible:
		return
	select.disable()
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
		selected = clamp(selected + 1, 0, characters.size() - 1)
		update_view()
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
		selected = clamp(selected - 1, 0, characters.size() - 1)
		update_view()
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		emit_signal("character_selected", characters[selected])
		pick_random_sfx(get_parent().get_node("sfx/char_select"))
		characters.remove(selected)
		selected = 0
		if characters.size() == 0:
			emit_signal("library_exhausted")
#			get_parent().arrow_hide()
#			get_parent().active = false
			placeholder.hide()
			return
		else:
			update_view()
