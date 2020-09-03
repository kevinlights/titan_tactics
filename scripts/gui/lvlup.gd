extends Control

var current_atk
var current_def
var current_hp

var new_atk
var new_def
var new_hp

var atlas = {
	Game.TYPE.FIGHTER: 0,
	Game.TYPE.ARCHER: 2,
	Game.TYPE.MAGE: 4
}

#should be called before leveling up
func get_current_stats(character):
	current_atk = character.atk
	current_def = character.def
	current_hp = character.max_hp

#should be called after the level and stats are increased
func on_level_up(character):
	$Control/Ok.grab_focus()
	$new_lvl.text = character.level
	$char_sprite.frame = atlas[character.character_class]
	$current_atk.text = current_atk
	$current_def.text = current_def
	$current_hp.text = current_hp
	new_atk = character.atk
	new_def = character.def
	new_hp = character.max_hp
	$new_atk.text = new_atk
	$new_def.text = new_def
	$new_hp.text = new_hp
	$current_atk.text = current_atk
	


func _on_ok_pressed():
	if !visible:
		return
	hide()
