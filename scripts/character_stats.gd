extends Resource
class_name CharacterStats

signal class_changed

export(int, "Swordsman", "Archer", "Mage") var character_class setget set_character_class, get_character_class
export(String) var name
export(int) var level = 1 setget set_level,get_level
export(int) var hp
export(int) var max_hp
export(int) var atk
export(int) var def
export(int) var atk_range
export(int) var mov_range
export(int) var heal
export(Resource) var item_atk
export(Resource) var item_def

var abilities
var control
var weakness
var strength
var xp = 0 # setget set_xp,get_xp
var xp_to_next = 1
var current_to_next = 0

func add_xp(more_xp):
	xp += more_xp
	current_to_next += more_xp
	print("xp gained ", more_xp)
	print("xp to next level ", xp_to_next)
	print("progress to next level ", current_to_next)
	if current_to_next >= xp_to_next:
		level_up()

func level_up():
	level += 1
	max_hp = (max_hp + (level + 1) * 2)
	hp = max_hp
	atk += level * rand_range(0, 2)
	def += level * rand_range(0, 2)
	current_to_next = current_to_next - xp_to_next
	xp_to_next = pow(level, 2)
	print("Level up")

#func set_xp(more_xp):
#	xp = more_xp
#
#func get_xp():
#	return xp

func set_level(lvl):
	level = lvl
	var default_stats = load("res://resources/class_stats.tres")
	generate(default_stats, character_class, control, level)
	
func get_level():
	return level

func set_character_class(new_character_class):
	character_class = new_character_class
	if item_atk and item_def:
		item_atk.character_class = new_character_class
		item_def.character_class = new_character_class
	var default_stats = load("res://resources/class_stats.tres")
	generate(default_stats, character_class, control, level)
	print("class changed emit singal")
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

func from_other(other_stats):
	print("Setting stats from other stats")
	character_class = other_stats.character_class
	level = other_stats.level
	name = other_stats.name
	print("hp ", other_stats.hp)
	hp = other_stats.hp
	max_hp = other_stats.hp
	atk = other_stats.atk
	def = other_stats.def
	atk_range = other_stats.atk_range
	mov_range = other_stats.mov_range
	item_atk = other_stats.item_atk
	item_def = other_stats.item_def
	heal = other_stats.heal

func from_defaults(request_class, request_control, atk = 1, def = 1, atk_range = 1, mov_range = 1, hp = 10):
	character_class = request_class
	control = request_control
	self.hp = hp
	self.max_hp = hp
	self.atk = atk
	self.def = def
	self.mov_range = mov_range
	self.atk_range = atk_range
	self.heal = 0
	item_atk = Item.new()
	item_def = Item.new()
	item_atk.generate(level, Item.SLOT.ATK, character_class)
	item_def.generate(level, Item.SLOT.DEF, character_class)

func generate(class_stats, request_class, request_control, level = 1):
	print("Regenerate stats")
	var default_stats = class_stats.archer
	default_stats = class_stats.archer
	if request_class == Game.TYPE.FIGHTER:
		default_stats = class_stats.swordsman
	elif request_class == Game.TYPE.MAGE:
		default_stats = class_stats.mage 
		heal = level
	character_class = default_stats.character_class
	item_atk = Item.new()
	item_def = Item.new()
	item_atk.generate(level, Item.SLOT.ATK, character_class)
	item_def.generate(level, Item.SLOT.DEF, character_class)
	control = request_control
	abilities = Game.class_stats.abilities[character_class]
	max_hp = floor(default_stats.hp + rand_range((level + 1) * 4, (level + 1) * 5) - 15)
	hp = floor(default_stats.hp + rand_range((level + 1) * 4, (level + 1) * 5) - 15)
	mov_range = default_stats.mov_range
	turn_limits.move_distance = default_stats.mov_range
	turn_limits.actions = 1 # Game.class_stats.actions[type]
	atk_range = default_stats.atk_range
	atk = default_stats.atk
	def = default_stats.def
	weakness = Game.class_stats.weakness[character_class]
	strength = Game.class_stats.strength[character_class]
	name = Game.character_names[rand_range(0, Game.character_names.size() - 1)]
	# don't want to take for ever to test death and level progression
	if Engine.editor_hint:
		property_list_changed_notify()
	else:
		if Game.sudden_death and control == Game.CONTROL.AI:
			hp = 1
			max_hp = 1
		
	
func has_ability(ability):
	return abilities.has(ability)
