extends Resource
class_name CharacterStats

signal class_changed
signal level_up

export(int, "Swordsman", "Archer", "Mage", "Boba", "Poison Boba") var character_class setget set_character_class, get_character_class
export(String) var name
export(int) var level = 1 setget set_level,get_level
export(int) var hp setget set_hp,get_hp
export(int) var max_hp
export(int) var atk
export(int) var def
export(int) var atk_range
export(int) var mov_range
export(int) var heal
export(Resource) var item_atk
export(Resource) var item_def
export(int, "Can't Recruit", "May Recruit", "Must Recruit") var recruit_mode = 0

#export(String, "default", "archer", "swordsman", "mage", "ai_archer", "ai_swordsman", "ai_mage", "hero", "antagonist", "antagonist_revealed", "old_man", "cyan") var portrait_override
export(String) var portrait_override
export(TT.CONTROL) var control = TT.CONTROL.AI

var abilities
#var control
var weakness
var strength
var xp = 0 # setget set_xp,get_xp
var xp_to_next = 1
var current_to_next = 0
var personality = 0

# fibronacci influences hp
# hp_up does nothing?
var fibonacci = [ 0, 2, 3, 4, 5, 6, 7, 7, 8, 8, 10, 12, 14 ]
var hp_up = [ 0, 2, 3, 4, 5, 6, 7, 7, 8, 8, 10, 12, 14 ]
var atk_up = [ 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1 ]
var def_up = [ 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ]
var mov_up = [ 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0 ]

var cant_carry = [ TT.TYPE.BOBA ]
enum PERSONALITY {
	AGGRESSIVE,
	NARCISSIST,
	GREEDY
}

func set_hp(value):
	hp = clamp(value, 0, 999)

func get_hp():
	return hp

func sequence_cumulative(sequence, position):
	var result = 0
	for x in range(min(position, sequence.size())):
		result += sequence[x]
	return result

func fibonacci_cumulative(position):
	var result = 0
	for x in range(min(position, fibonacci.size())):
		result += fibonacci[x]
	return result

func add_xp(more_xp):
	if level == 0:
		return
	xp += more_xp
	current_to_next += more_xp
	print("xp gained ", more_xp)
	print("xp to next level ", xp_to_next)
	print("progress to next level ", current_to_next)
	if current_to_next >= xp_to_next:
		level_up()

func level_up():
	var lvl_up = clamp(level, 0, atk_up.size() - 2)
	var stats_diff = {
		"atk": atk_up[lvl_up + 1],
		"def": def_up[lvl_up + 1],
		"hp": hp_up[lvl_up + 1]
	}
	level += 1
	atk += stats_diff.atk
	def += stats_diff.def
	max_hp += stats_diff.hp
	hp = max_hp
	current_to_next = current_to_next - xp_to_next
	xp_to_next = pow(level, 2)
	print("Level up")
	emit_signal("level_up", stats_diff, self)

#func set_xp(more_xp):
#	xp = more_xp
#
#func get_xp():
#	return xp

func set_level(lvl):
	level = lvl
#	var default_stats = load("res://resources/class_stats.tres")
#	generate(default_stats, character_class, control, level)
	
func get_level():
	return level

func set_character_class(new_character_class):
	character_class = new_character_class
	if item_atk and item_def:
		item_atk.character_class = new_character_class
		item_def.character_class = new_character_class
#	var default_stats = load("res://resources/class_stats.tres")
	generate(Game.default_stats, character_class, control, level)
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
	hp = other_stats.hp
	max_hp = other_stats.hp
	atk = other_stats.atk
	def = other_stats.def
	atk_range = other_stats.atk_range
	mov_range = other_stats.mov_range
	item_atk = other_stats.item_atk
	item_def = other_stats.item_def
	heal = other_stats.heal
	xp_to_next = level * level
	recruit_mode = other_stats.recruit_mode
	portrait_override = other_stats.portrait_override
	control = other_stats.control

func from_defaults(request_class, request_control, request_atk = 1, request_def = 1, request_atk_range = 1, request_mov_range = 1, request_hp = 10):
	character_class = request_class
	control = request_control
	self.hp = request_hp
	self.max_hp = request_hp
	self.atk = request_atk
	self.def = request_def
	self.mov_range = request_mov_range
	self.atk_range = request_atk_range
	self.heal = 0
	if !(request_class in cant_carry):
		item_atk = Item.new()
		item_def = Item.new()
		item_atk.create()
		item_def.create()
#		item_atk.generate(level, Item.SLOT.ATK, character_class)
#		item_def.generate(level, Item.SLOT.DEF, character_class)

func generate(class_stats, request_class, request_control, request_level = 1, force = false):
	var rng = RandomNumberGenerator.new()
	if !(request_class in cant_carry):
		if !item_atk:
			item_atk = Item.new()
			item_atk.create()
		if !item_def:
			item_def = Item.new()
			item_def.create()
	weakness = TT.class_stats.weakness[character_class]
	strength = TT.class_stats.strength[character_class]
	abilities = TT.class_stats.abilities[character_class]
	level = request_level
	xp_to_next = level * level
	rng.randomize()
	personality = rng.randi_range(0, 2)
	# prevent re-generating character on spawn
	if not Engine.editor_hint and not force:
		return
	print("Regenerate stats")
	var default_stats = class_stats.archer
	default_stats = class_stats.archer
	if request_class == TT.TYPE.FIGHTER:
		default_stats = class_stats.swordsman
	elif request_class == TT.TYPE.MAGE:
		default_stats = class_stats.mage 
		heal = level
	elif request_class == TT.TYPE.BOBA:
		default_stats = class_stats.boba
	elif request_class == TT.TYPE.POISON_BOBA:
		default_stats = class_stats.poison_boba
	character_class = default_stats.character_class
	control = request_control
	abilities = TT.class_stats.abilities[character_class]
	max_hp = default_stats.hp + fibonacci_cumulative(level)
	hp = max_hp # floor(default_stats.hp + rand_range((level + 1) * 4, (level + 1) * 5) - 15)
	mov_range = default_stats.mov_range
	turn_limits.move_distance = default_stats.mov_range
	turn_limits.actions = 1 # TT.class_stats.actions[type]
	atk_range = default_stats.atk_range
	atk = default_stats.atk + sequence_cumulative(atk_up, level)
	def = default_stats.def + sequence_cumulative(def_up, level)
	# don't regenerate name if this character already has one
	if name == "":
		name = TT.character_names[rand_range(0, TT.character_names.size() - 1)]
	# don't want to take for ever to test death and level progression
	if Engine.editor_hint:
		property_list_changed_notify()
	else:
		if TT.sudden_death and control == TT.CONTROL.AI:
			hp = 1
			max_hp = 1
		
	
func has_ability(ability):
	return abilities.has(ability)
	
func to_save_data():
	var output = {
		"item_atk": inst2dict(item_atk),
		"item_def": inst2dict(item_def),
		"character_class": character_class,
		"level": level,
		"control": control,
		"xp": xp,
		"personality": personality,
		"portrait_override": portrait_override,
		"name": name,
	}
	output.item_atk.effect = inst2dict(item_atk.effect)
	output.item_def.effect = inst2dict(item_def.effect)
	return output
	
func from_save_data(class_stats, data):
	name = data.name
	data.item_atk.level = int(data.item_atk.level)
	data.item_atk.character_class = int(data.item_atk.character_class)
	item_atk = dict2inst(data.item_atk)
	item_atk.effect = dict2inst(item_atk.effect)
	
	data.item_def.level = int(data.item_def.level)
	data.item_def.character_class = int(data.item_def.character_class)
	item_def = dict2inst(data.item_def)
	item_def.effect = dict2inst(item_def.effect)
	
	character_class = int(data.character_class)
	level = data.level
	control = data.control
	xp = data.xp
	personality = int(data.personality)
	portrait_override = data.portrait_override
	
	weakness = TT.class_stats.weakness[character_class]
	strength = TT.class_stats.strength[character_class]
	abilities = TT.class_stats.abilities[character_class]
	xp_to_next = pow(level, 2)
	heal = level
	if level > 1:
		current_to_next = xp - pow(level - 1, 2)
	
	var default_stats = class_stats.archer
	if character_class == TT.TYPE.FIGHTER:
		default_stats = class_stats.swordsman
	elif character_class == TT.TYPE.MAGE:
		default_stats = class_stats.mage 
		heal = level
	elif character_class == TT.TYPE.BOBA:
		default_stats = class_stats.boba
	max_hp = default_stats.hp + fibonacci_cumulative(level)
	hp = max_hp # floor(default_stats.hp + rand_range((level + 1) * 4, (level + 1) * 5) - 15)
	mov_range = default_stats.mov_range
	turn_limits.move_distance = default_stats.mov_range
	turn_limits.actions = 1 # TT.class_stats.actions[type]
	atk_range = default_stats.atk_range
	atk = default_stats.atk + sequence_cumulative(atk_up, level)
	def = default_stats.def + sequence_cumulative(def_up, level)
