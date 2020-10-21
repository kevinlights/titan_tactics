extends Node

signal orientation_changed
signal orientation_changed_clockwise
signal orientation_changed_counter_clockwise

var team = []
var level = 0
var camera_orientation = TT.CAMERA.NORTH setget set_camera_orientation, get_camera_orientation

func set_camera_orientation(new_orientation):

	if new_orientation > camera_orientation or (camera_orientation == TT.CAMERA.WEST and new_orientation == TT.CAMERA.NORTH):
		if not (camera_orientation == TT.CAMERA.NORTH and new_orientation == TT.CAMERA.WEST):
			camera_orientation = new_orientation
			emit_signal("orientation_changed_clockwise")
			print("orientation_changed_clockwise")
	if new_orientation < camera_orientation or (camera_orientation == TT.CAMERA.NORTH and new_orientation == TT.CAMERA.WEST):
		if not (camera_orientation == TT.CAMERA.WEST and new_orientation == TT.CAMERA.NORTH):
			camera_orientation = new_orientation
			emit_signal("orientation_changed_counter_clockwise")
			print("orientation_changed_counter_clockwise")
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

func setup_new_game():
	level = 0
	team = []
	var default_stats = load("res://resources/class_stats.tres")
	var character = CharacterStats.new()
#	character.from_defaults(TYPE.FIGHTER, CONTROL.PLAYER)
	character.generate(default_stats, TT.TYPE.FIGHTER, TT.CONTROL.PLAYER, 1, true)
	character.name = "Kris"
	character.portrait_override = "hero"
	team.append(character)
	var character2 = CharacterStats.new()
	character2.generate(default_stats, TT.TYPE.ARCHER, TT.CONTROL.PLAYER, 1, true)
	character2.name = "Bowie"
	character2.portrait_override = "bowie"
	team.append(character2)
