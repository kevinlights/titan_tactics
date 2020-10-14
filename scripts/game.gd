extends Node

signal orientation_changed

var team = []
var level = 0
var camera_orientation = TT.CAMERA.NORTH setget set_camera_orientation, get_camera_orientation

func set_camera_orientation(new_orientation):
	camera_orientation = new_orientation
	emit_signal("orientation_changed")

func get_camera_orientation():
	return camera_orientation

func get_level_count():
	return TT.levels.size()

func get_level():
#	var names = TT.levels
	return TT.levels[level].scene

func get_theme():
#	var lvl = get_level()
	return TT.levels[level].music
#	return TT.levels[lvl]

func _ready():
	var default_stats = load("res://resources/class_stats.tres")
	var character = CharacterStats.new()
#	character.from_defaults(TYPE.FIGHTER, CONTROL.PLAYER)
	character.generate(default_stats, TT.TYPE.FIGHTER, TT.CONTROL.PLAYER, 1, true)
	character.name = "Rolf"
	character.portrait_override = PT_Dialogue.PORTRAIT.HERO
	team.append(character)
	var character2 = CharacterStats.new()
	character2.generate(default_stats, TT.TYPE.ARCHER, TT.CONTROL.PLAYER, 1, true)
	character2.name = "Cyan"
	character2.portrait_override = PT_Dialogue.PORTRAIT.CYAN
	team.append(character2)
	
