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
	Game.TYPE.OTHER: [ "shield", "buckler", "plate", "helm", "tunic", "jacket", "chain", "mail" ]
}

func create(item_name = 0, attack_buff = 0, range_buff = 0, accuracy_buff = 0, heal_buff = 0):
	name = item_name
	attack = attack_buff
	attack_range = range_buff
	heal = heal_buff

func generate(item_level, equipment_slot, item_class):
	character_class = item_class
	level = clamp(item_level, 0, 5)
#	self.equipment_slot = equipment_slot
	var prefix = item_prefix[level][rand_range(0, item_prefix[level].size() - 1)]
	var suffix = item_names[character_class][rand_range(0, item_names[character_class].size() - 1)]
	if equipment_slot == SLOT.DEF:
		suffix = item_names[Game.TYPE.OTHER][rand_range(0, item_names[Game.TYPE.OTHER].size() - 1)]
		
	name = prefix + " " + suffix
	if equipment_slot == SLOT.ATK:
		attack = floor(level * rand_range(level, level * 1.5))
		attack_range = floor(level * rand_range(level, level * 1.5))
	if equipment_slot == SLOT.DEF:
		defense = floor(level * rand_range(level, level * 1.5))
	heal = 0
	if character_class == Game.TYPE.MAGE:
		heal = floor(1 + level * rand_range(0, level * 2))
	if Engine.editor_hint:
		property_list_changed_notify()
	
