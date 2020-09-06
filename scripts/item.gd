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
	SLOT.ATK: 	 [ 0, 0.75, 1.25, 1.75, 1.75, 1.75, 1.75, 1.75, 1.75, 1.75, 1.75 ],
	SLOT.DEF: 	 [ 0, 0.75, 1.25, 1.75, 1.75, 1.75, 1.75, 1.75, 1.75, 1.75, 1.75 ],
	"atk_range": [ 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 ],
	"heal": 	 [ 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 ],
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
	0: [ "Lesser", "Small", "Rusted", "Broken", "Weak", "Puny", "Light" ],
	1: [ "Minor", "Common" ],
	2: [ "Iron", "Forged", "Hard" ],
	3: [ "Steel", "Sharp", "Elven" ],
	4: [ "Strong", "Shiny", "Silver" ],
	5: [ "Rare", "Epic", "Deadly", "Great" ]
}

var item_names = {
	Game.TYPE.FIGHTER: [ "Sword", "Cleaver", "Knife", "Dagger" ],
	Game.TYPE.ARCHER: [ "Bow", "Longbow" ],
	Game.TYPE.MAGE: [ "Wand", "Staff", "Scepter" ],
	Game.TYPE.OTHER: [ "Plate", "Helm", "Tunic", "Jacket", "Chain", "Mail", "Boots", "Vest", "Suit", "Shirt"]
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
	
