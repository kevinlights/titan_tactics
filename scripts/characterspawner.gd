class_name CharacterSpawner
extends Sprite
tool

export(Resource) var stats

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	# default_stats, request_class, request_control
	var default_stats = load("res://resources/class_stats.tres")

	if !stats:
		print("create stats object")
		stats = CharacterStats.new(default_stats, Game.TYPE.ARCHER, Game.CONTROL.AI)
	stats.connect("class_changed", self, "set_sprite")
	set_sprite()

func _ready():
	add_to_group("ai_spawns")
	print(stats)
	if !stats:
		print("Corrupt spawn!")

func set_sprite():
#	if stats:
	if Engine.editor_hint:
		match stats.character_class:
			Game.TYPE.ARCHER:
				texture = load("res://gfx/archer.png")
			Game.TYPE.FIGHTER:
				texture = load("res://gfx/swordsman.png")
			Game.TYPE.MAGE:
				texture = load("res://gfx/mage.png")
	
