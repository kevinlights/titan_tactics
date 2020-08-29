extends Resource
class_name CharacterStats

signal class_changed

export(int, "Swordsman", "Archer", "Mage") var character_class setget set_character_class, get_character_class
export(String) var name
export(int) var level = 1
export(int) var hp
export(int) var max_hp
export(int) var atk
export(int) var def
export(int) var atk_range
export(int) var mov_range

var is_stats = true
var abilities
var control
var weakness
var strength

func set_character_class(new_character_class):
	character_class = new_character_class
	emit_signal("class_changed")

func get_character_class():
	return character_class

var items = {
	"atk": null,
	"def": null
}

var turn_limits = {
	"move_distance": mov_range,
	"actions": 1 # attack, heal, guard
}

func reset_turn():
	turn_limits.move_distance = mov_range
	turn_limits.actions = 1

func _ready():
	pass # Replace with function body.

func _init(request_class, request_control, atk = 1, def = 1, atk_range = 1, mov_range = 1, hp = 10):
	character_class = request_class
	control = request_control
	self.hp = hp
	self.max_hp = hp
	self.atk = atk
	self.def = def
	self.mov_range = mov_range
	self.atk_range = atk_range
	items.atk = Item.new()
	items.def = Item.new()

func generate(class_stats, request_class, request_control):
	var default_stats = class_stats.archer
	default_stats = class_stats.archer
	if request_class == Game.TYPE.FIGHTER:
		default_stats = class_stats.swordsman
	elif request_class == Game.TYPE.MAGE:
		default_stats = class_stats.mage 
#
#	items.atk = Item.new()
#	items.def = Item.new()
	character_class = default_stats.character_class
	items.atk.generate(Game.level, character_class)
	control = request_control
	level = Game.level
	abilities = Game.class_stats.abilities[character_class]
	max_hp = floor(default_stats.hp + rand_range((Game.level + 1) * 4, (Game.level + 1) * 5) - 15)
	hp = floor(default_stats.hp + rand_range((Game.level + 1) * 4, (Game.level + 1) * 5) - 15)
	mov_range = default_stats.mov_range
	turn_limits.move_distance = default_stats.mov_range
	turn_limits.actions = 1 # Game.class_stats.actions[type]
	atk_range = default_stats.atk_range
	#attack_damage = Game.class_stats.damage[type]	
	
#	if control == Game.CONTROL.AI:
#		match Game.level:
#			0:
#				attack_damage = default_stats.atk
#			1:
#				attack_damage = default_stats.atk
#			2:
#				attack_damage = default_stats.atk
#			3:
#				attack_damage = default_stats.atk * 0.8
#			4:
#				attack_damage = default_stats.atk * 0.6
#			5:
#				attack_damage = default_stats.atk * 0.4
#			6:
#				attack_damage = default_stats.atk * 0.3
#	else: 
	atk = default_stats.atk
				
	def = default_stats.def
#	heal = default_stats.atk
	weakness = Game.class_stats.weakness[character_class]
	strength = Game.class_stats.strength[character_class]
	name = Game.character_names[rand_range(0, Game.character_names.size() - 1)]
	# don't want to take for ever to test death and level progression
	if Game.sudden_death and control == Game.CONTROL.AI:
		hp = 1
		max_hp = 1
	
func has_ability(ability):
	return abilities.has(ability)
