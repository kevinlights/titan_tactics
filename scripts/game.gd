extends Node

var team = []
var level = 0

func get_level_count():
	return TT.levels.keys().size()

func get_level():
	var names = TT.levels.keys()
	return names[level]

func get_theme():
	var lvl = get_level()
	return TT.levels[lvl]

func _ready():
	var default_stats = load("res://resources/class_stats.tres")
	var character = CharacterStats.new()
#	character.from_defaults(TYPE.FIGHTER, CONTROL.PLAYER)
	character.generate(default_stats, TT.TYPE.FIGHTER, TT.CONTROL.PLAYER, 1, true)
	character.name = "Rolf"
	character.portrait_override = PT_Dialogue.PORTRAIT.HERO
	team.append(character)
	
