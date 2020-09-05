tool
extends Resource
class_name Item

export(int, "Swordsman", "Archer", "Mage") var character_class setget set_class, get_class
export(int, "ATK", "DEF") var equipment_slot = 0 setget set_equipment_slot,get_equipment_slot
export(int) var level = 0 setget set_level,get_level
export(String) var name = "unknown item"
export(int) var attack = 0
export(int) var attack_range = 0
export(int) var defense = 0
export(int) var heal = 0

enum SLOT {
	ATK = 0,
	DEF
}

var up = {
	SLOT.ATK: 	 [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 ],
	SLOT.DEF: 	 [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 ],
	"atk_range": [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 ],
	"heal": 	 [ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987 ]
}


func set_equipment_slot(slot):
	equipment_slot = slot
	generate(level, slot, character_class)

func get_equipment_slot():
	return equipment_slot

func set_level(item_level):
	level = item_level
	generate(level, equipment_slot, character_class)

func get_level():
	return level

func set_class(item_class):
	character_class = item_class
	generate(level, equipment_slot, character_class)

func get_class():
	return character_class

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
	Game.TYPE.MAGE: [ "wand", "staff", "scepter" ],
	Game.TYPE.OTHER: [ "plate", "helm", "tunic", "jacket", "chain", "mail", "boots"]
}

func sequence_cumulative(sequence, position):
	var result = 0
	for x in range(position):
		result += sequence[x]
	return result

func create():
	name = "empty hand"
	character_class = 0
	attack = 0
	attack_range = 0
	defense = 0
	heal = 0

func generate(item_level, slot, item_class):
	character_class = item_class
	level = clamp(item_level, 0, 5)
	equipment_slot = slot
	var prefix = item_prefix[level][rand_range(0, item_prefix[level].size() - 1)]
	var suffix = item_names[character_class][rand_range(0, item_names[character_class].size() - 1)]
	if equipment_slot == SLOT.DEF:
		suffix = item_names[Game.TYPE.OTHER][rand_range(0, item_names[Game.TYPE.OTHER].size() - 1)]
		
	name = prefix + " " + suffix
	if equipment_slot == SLOT.ATK:
		attack = 1 + sequence_cumulative(up[equipment_slot], level)
		attack_range = 1 + sequence_cumulative(up.atk_range, level)
	if equipment_slot == SLOT.DEF:
		defense = 1 + sequence_cumulative(up[equipment_slot], level)
#		defense = floor(level * rand_range(level, level * 1.5))
	heal = 0
	if character_class == Game.TYPE.MAGE:
		heal = 1 + sequence_cumulative(up["heal"], level)		
	if Engine.editor_hint:
		property_list_changed_notify()
	
