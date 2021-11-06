extends Resource
class_name CharacterStats

signal class_changed
signal level_up

# minimum shared vars
export(int, "Swordsman", "Archer", "Mage", "Boba", "Poison Boba") var character_class setget set_character_class, get_character_class
export(String) var name
export(int) var level = 1 setget set_level,get_level
export(int) var hp setget set_hp,get_hp
export(int) var max_hp
export(int) var atk
export(int) var def
export(int) var atk_range
export(int) var mov_range

export(Resource) var item_atk
export(Resource) var item_def

export(String) var portrait_override
export(TT.CONTROL) var control = TT.CONTROL.AI

var abilities
var xp = 0
var xp_to_next = 1
var current_to_next = 0

var turn_limits = {
	"move_distance": mov_range,
	"move_actions": 1,
	"actions": 1 # attack, heal, guard
}


func reset_turn():
	property_list_changed_notify()
	turn_limits.move_distance = mov_range
	turn_limits.actions = 1
	turn_limits.move_actions = 1

# getter/setters
func set_character_class(new_character_class):
	push_error("Needs to be implemented in subclass")

func get_character_class():
	push_error("Needs to be implemented in subclass")

func set_level(lvl):
	push_error("Needs to be implemented in subclass")
	
func get_level():
	return level;

func set_hp(value):
	hp = clamp(value, 0, 999)

func get_hp():
	return hp

func add_xp(enemy_lvl):
	# TODO: rename function to make it clearer that it adds based on computed lvl
	if level == 0:
		return
	# below is enemy death exponential xp curve
	# 50 * lvl ^ 0.36673ish
	var more_xp = round(50 * pow(enemy_lvl, log(3) / log(20)))
	xp += more_xp
	current_to_next += more_xp
	print("xp gained ", more_xp)
	print("xp to next level ", xp_to_next)
	print("progress to next level ", current_to_next)
	if current_to_next >= xp_to_next:
		level_up()

func level_up():
	push_error("Needs to be implemented in subclass")
