extends Object
class_name Item

var attack = 0
var attack_range = 0
var accuracy = 0
var defense = 0
var heal = 0
var name = "unknown item"
var level = 0
var type

var item_prefix = {
	0: [ "lesser", "small", "rusted", "broken", "weak", "puny", "light" ],
	1: [ "minor", "common" ],
	2: [ "iron", "forged", "hard" ],
	3: [ "steel", "sharp", "elven" ],
	4: [ "strong", "shiny", "silver" ],
	5: [ "rare", "epic", "deadly", "great" ]
}

var item_names = {
	Game.TYPE.FIGHTER: [ "sword", "cleaver", "knife", "dagger" ],
	Game.TYPE.ARCHER: [ "bow", "longbow" ],
	Game.TYPE.MAGE: [ "wand", "staff", "scepter" ]
}
func _init(item_name = 0, attack_buff = 0, range_buff = 0, accuracy_buff = 0, heal_buff = 0):
	name = item_name
	attack = attack_buff
	accuracy = accuracy_buff
	attack_range = range_buff
	heal = heal_buff

func generate(level, item_type):
	type = item_type
	level = clamp(level, 0, 5)
	var prefix = item_prefix[level][rand_range(0, item_prefix[level].size() - 1)]
	var suffix = item_names[type][rand_range(0, item_names[type].size() - 1)]
	name = prefix + " " + suffix
	attack = floor(level * rand_range(level, level * 1.5))
	attack_range = floor(level * rand_range(level, level * 1.5))
	accuracy = level
	heal = 0
	if type == Game.TYPE.MAGE:
		heal = floor(1 + level * rand_range(0, level * 2))
	
