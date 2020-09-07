extends Control

signal character_selected
signal library_exhausted

var characters = []
var library = []
var selected = 0

onready var select = get_parent().get_parent().get_node("select")

var atlas_frames = {
	Game.TYPE.ARCHER: "archer",
	Game.TYPE.FIGHTER: "fighter",
	Game.TYPE.MAGE: "mage"
}

func set_characters(list):
	library = list
	characters = library.duplicate()
	update_view()

func _ready():
	pass

func _process(delta):
	if !visible:
		return
	if select.animation != "fighter" and select.animation != "mage" and select.animation != "archer":
		select.play(atlas_frames[characters[selected].character_class])
	$levelline2.set_point_position(1, Vector2(characters[selected].xp/characters[selected].xp_to_next*28, 0))
	$hpline2.set_point_position(1, Vector2(characters[selected].hp/characters[selected].max_hp * 61, 0))
	if characters.size() == 1:
		$Arrows.hide()
	else:
		$Arrows.show()

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
	$name.text = characters[selected].name
	if $name.text in get_parent().get_node("battle").special_names:
		$Portrait.play($name.text)
	if !$name.text in get_parent().get_node("battle").special_names:
		$Portrait.play("portraits")
		$Portrait.frame = characters[selected].character_class
		$Portrait.playing = false
	
	$atk.text = "%02d" % int(round((characters[selected].atk + characters[selected].item_atk.attack)))
	$hp.text =  "%02d" % int(round(characters[selected].hp))
	$hp.text += "/" + str(characters[selected].max_hp)
	$lvl.text =  "%02d" % characters[selected].level
	$def.text =  "%02d" % int(round((characters[selected].def + characters[selected].item_def.defense)))
#	var current = characters[selected]
	
func _input(event):
	if !visible:
		return
	select.disable()
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
			get_parent().arrow_hide()
			get_parent().active = false
			return
	selected = clamp(selected, 0, characters.size() - 1)
	update_view()
	
