extends Control

signal close

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

#should be called after the level and stats are increased
func on_level_up(diff, character):
	$char_sprite.frame = atlas[character.character_class]
	$new_lvl.text = "%02d" % (character.level)
	$current_hp.text = "%02d" % (character.max_hp - diff.hp)
	$current_atk.text = "%02d" % (character.atk - diff.atk)
	$current_def.text = "%02d" % (character.def - diff.def)
	$new_atk.text = "%02d" % (character.atk)
	$new_def.text = "%02d" % (character.def)
	$new_hp.text = "%02d" % (character.max_hp)
	$name.text = character.name
	show()
	$Control/Ok.grab_focus()


func _on_ok_pressed():
	if !visible:
		return
	hide()
	emit_signal("close")
