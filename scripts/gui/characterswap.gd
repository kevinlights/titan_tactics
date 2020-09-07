extends Control

signal character_selected
signal library_exhausted

var current_character

var end_x = 36
var start_x = -36
var start = 0
var ttl = 60

var moving_back = false

onready var world = get_parent().get_parent()

func _ready():
	pass

func _process(delta):
	if !visible or world.current[Game.CONTROL.PLAYER].size() == 0:
		return
	get_parent().make_select_blank()
	var now = OS.get_ticks_msec()
	if !moving_back:
		if $box_ally.position.x < end_x:
			$box_ally.position.x = lerp(start_x, end_x, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = end_x
	current_character = world.get_current().character
	$box_ally/levelline2.set_point_position(1, Vector2(current_character.xp/current_character.xp_to_next*28, 0))
	$box_ally/hpline2.set_point_position(1, Vector2(current_character.hp/current_character.max_hp * 61, 0))
	if world.current[world.current_turn].size() == 1:
		$Arrows.hide()
	else:
		$Arrows.show()

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()
	
func update_view():
	if !current_character:
		return
	var animation = "fighter"
	$box_ally/name.text = current_character.name
	if $box_ally/name.text in get_parent().get_node("battle").special_names:
		$box_ally/Portrait.play($box_ally/name.text)
	if !$box_ally/name.text in get_parent().get_node("battle").special_names:
		$box_ally/Portrait.play("portraits")
		$box_ally/Portrait.frame = current_character.character_class
		$box_ally/Portrait.playing = false
	
	$box_ally/atk.text = "%02d" % int(round(current_character.atk + current_character.item_atk.attack))
	$box_ally/hp.text =  "%02d" % current_character.hp
	$box_ally/hp.text += "/" + str(current_character.max_hp)
	$box_ally/lvl.text =  "%02d" % current_character.level
	$box_ally/def.text =  "%02d" % int(round(current_character.def + current_character.item_def.defense))
#	var current = characters[selected]
	
func _input(event):
	if !visible:
		return
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
		check_exhausted(1)
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
		check_exhausted(-1)
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		get_parent().active = false
		pick_random_sfx(get_parent().get_node("sfx/char_select"))
		get_parent().arrow_hide()
		call_deferred("hide")
		world.get_node("select").call_deferred("enable")
	if event.is_action("ui_cancel") && !event.is_echo() && event.is_pressed():
		get_parent().get_parent().end_turn()
		get_parent().arrow_hide()
		hide()
		return
	update_view()
		#characters.remove(selected)
		#if characters.size() == 0:
		#	emit_signal("library_exhausted")
		#	return
	#selected = clamp(selected, 0, characters.size() - 1)
	
	
func check_exhausted(direction):
	get_parent().get_parent().advance_turn(0, direction)
	current_character = world.get_current().character
	
