extends Control

signal closed

var current_atk
var current_def
var current_hp

var new_atk
var new_def
var new_hp

var atlas = {
	TT.TYPE.FIGHTER: "swordsman",
	TT.TYPE.ARCHER: "archer",
	TT.TYPE.MAGE: "mage"
}

func on_level_up(diff, character):
	get_tree().get_root().get_node("World/gui/sfx/level_up").play()
	$char_sprite.play(atlas[character.character_class])
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

func init(args):
	on_level_up(args[0], args[1])

func out():
	hide()

func _on_ok_pressed():
	if !visible:
		return
	get_parent().back()
	emit_signal("closed")
