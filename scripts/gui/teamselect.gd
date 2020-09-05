extends Control

signal character_selected
signal library_exhausted

var characters = []
var library = []
var selected = 0

func set_characters(list):
	library = list
	characters = library.duplicate()
	update_view()

func _ready():
	pass

func _process(delta):
	if !visible:
		return
	$levelline2.set_point_position(1, Vector2(characters[selected].xp/characters[selected].xp_to_next*28, 0))
	$hpline2.set_point_position(1, Vector2(characters[selected].hp/characters[selected].max_hp * 61, 0))

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()
	
func update_view():
	var animation = "fighter"
	#match characters[selected].character_class:
	#	Game.TYPE.ARCHER:
	#		animation = "archer"
	#	Game.TYPE.MAGE:
	#		animation = "mage"
	$Portrait.frame = characters[selected].character_class
	$name.text = characters[selected].name
	$atk.text = "%02d" % (characters[selected].atk + characters[selected].item_atk.attack)
	$hp.text =  "%02d" % characters[selected].hp
	$lvl.text =  "%02d" % characters[selected].level
	$def.text =  "%02d" % (characters[selected].def + characters[selected].item_def.defense)
#	var current = characters[selected]
	
func _input(event):
	if !visible:
		return
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
		selected += 1
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
		selected -= 1		
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		emit_signal("character_selected", characters[selected])
		pick_random_sfx(get_parent().get_node("sfx/char_select"))
		characters.remove(selected)
		if characters.size() == 0:
			emit_signal("library_exhausted")
			return
	
	selected = clamp(selected, 0, characters.size() - 1)
	if selected == 0:
		$Arrows.hide()
	else:
		$Arrows.show()
	update_view()
	
