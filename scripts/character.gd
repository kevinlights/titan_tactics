extends Object
class_name Character

var type
var control
var abilities
var attack_range
var attack_damage
var defense
var max_hp
var hp
var heal
var weakness
var strength
var name
var item

var class_stats = load("res://resources/class_stats.tres")
var default_stats

var turn_limits = {
	"move_distance": 64,
	"actions": 1 # attack, heal, guard
}

func end_turn():
	turn_limits.move_distance = default_stats.mov_range
	turn_limits.actions = 1 # Game.class_stats.actions[type]

func _init(request_type, request_control):
	default_stats = class_stats.archer
	if request_type == Game.TYPE.FIGHTER:
		default_stats = class_stats.swordsman
	elif request_type == Game.TYPE.MAGE:
		default_stats = class_stats.mage 
	
	item = Item.new()
	item.generate(Game.level, request_type)
	type = request_type
	control = request_control
	
	abilities = Game.class_stats.abilities[type]
	max_hp = floor(default_stats.hp + rand_range((Game.level + 1) * 4, (Game.level + 1) * 5) - 15)
	hp = floor(default_stats.hp + rand_range((Game.level + 1) * 4, (Game.level + 1) * 5) - 15)
	turn_limits.move_distance = default_stats.mov_range
	turn_limits.actions = 1 # Game.class_stats.actions[type]
	attack_range = default_stats.atk_range
	#attack_damage = Game.class_stats.damage[type]	
	
	if control == Game.CONTROL.AI:
		match Game.level:
			0:
				attack_damage = default_stats.atk
			1:
				attack_damage = default_stats.atk
			2:
				attack_damage = default_stats.atk
			3:
				attack_damage = default_stats.atk * 0.8
			4:
				attack_damage = default_stats.atk * 0.6
			5:
				attack_damage = default_stats.atk * 0.4
			6:
				attack_damage = default_stats.atk * 0.3
	else: 
		attack_damage = default_stats.atk
				
	defense = default_stats.def
	heal = default_stats.atk
	weakness = Game.class_stats.weakness[type]
	strength = Game.class_stats.strength[type]
	name = Game.character_names[rand_range(0, Game.character_names.size() - 1)]
	# don't want to take for ever to test death and level progression
	if Game.sudden_death and control == Game.CONTROL.AI:
		hp = 1
		max_hp = 1

func has_ability(ability):
	return abilities.has(ability)
