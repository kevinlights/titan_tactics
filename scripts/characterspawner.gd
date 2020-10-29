class_name CharacterSpawner
extends Sprite3D
tool

export(Resource) var stats
export(Resource) var dialogue
export(Resource) var recruit_dialogue
export(Resource) var death_dialogue

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	print("spawn entered tree")
	pixel_size = 0.04
	billboard = SpatialMaterial.BILLBOARD_ENABLED
	translation.y = 0.347
	call_deferred("set_up_editor")
#	set_up_editor()
#	if Engine.editor_hint:
#		var default_stats = load("res://resources/class_stats.tres")
#		if !stats:
#			print("create stats object")
#			stats = CharacterStats.new()
#			stats.from_defaults(default_stats, TT.TYPE.ARCHER, TT.CONTROL.AI)
#		if !dialogue:
#			dialogue = PT_Dialogue.new()
#		if !recruit_dialogue:
#			recruit_dialogue = PT_Dialogue.new()
#		if stats.is_connected("class_changed", self, "set_sprite"):
#			stats.disconnect("class_changed", self, "set_sprite")
#		stats.connect("class_changed", self, "set_sprite")
#		call_deferred("set_sprite")
#
#func _init():
#	set_up_editor()
#	add_to_group("ai_spawn")
##	print(stats)
##	if !stats:
##		print("Corrupt spawn in init!")
##	else:
##		print(stats)
func set_up_editor():
	if Engine.editor_hint:
		if !stats:
			var default_stats = load("res://resources/class_stats.tres")
			print("create stats object")
			stats = CharacterStats.new()
			stats.from_defaults(default_stats, TT.TYPE.ARCHER, TT.CONTROL.AI)
		else:
			var force_reinit_stats = CharacterStats.new()
			force_reinit_stats.from_other(stats)
			stats = force_reinit_stats
			property_list_changed_notify()
		if !dialogue:
			dialogue = PT_Dialogue.new()
		if !recruit_dialogue:
			recruit_dialogue = PT_Dialogue.new()
		if stats.is_connected("class_changed", self, "set_sprite"):
			stats.disconnect("class_changed", self, "set_sprite")
		print("connect class_changed signal")
		stats.connect("class_changed", self, "set_sprite")
#		else:
#			print("Apparenty already connected")
		call_deferred("set_sprite")

func _ready():
	print("spawn ready")
	add_to_group("ai_spawns")
	set_up_editor()

func set_sprite():
	if Engine.editor_hint:
		print("setting sprite")
		match stats.character_class:
			TT.TYPE.ARCHER:
				texture = load("res://gfx/archer.png")
			TT.TYPE.FIGHTER:
				texture = load("res://gfx/swordsman.png")
			TT.TYPE.MAGE:
				texture = load("res://gfx/mage.png")
			TT.TYPE.BOBA:
				texture = load("res://gfx/mage.png")
		property_list_changed_notify()
