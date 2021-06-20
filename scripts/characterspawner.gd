class_name CharacterSpawner
extends Sprite3D
tool

export(Resource) var stats
export(Resource) var dialogue
export(Resource) var recruit_dialogue
export(Resource) var death_dialogue

export(String) var spawn_trigger = "level_start"

var has_spawned = false

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	print("spawn entered tree")
	pixel_size = 0.06 #0.04
	centered = false
	axis = 1
	billboard = SpatialMaterial.BILLBOARD_DISABLED
	translation.y = 0.2 #347
	call_deferred("set_up_editor")
	if not Engine.editor_hint:
		translation.z -= 1
		hide()

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
		if stats.is_connected("class_changed", self, "set_sprite"):
			stats.disconnect("class_changed", self, "set_sprite")
		print("connect class_changed signal")
		stats.connect("class_changed", self, "set_sprite")
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
				texture = load("res://gfx/boba.png")
			TT.TYPE.POISON_BOBA:
				texture = load("res://gfx/boba.png")
		property_list_changed_notify()
