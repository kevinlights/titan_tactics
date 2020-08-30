class_name CharacterSpawner
extends Sprite
tool

export(Resource) var stats
export(Resource) var dialogue
export(Resource) var recruit_dialogue

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	if Engine.editor_hint:
		var default_stats = load("res://resources/class_stats.tres")
		if !stats:
			print("create stats object")
			stats = CharacterStats.new()
			stats.from_defaults(default_stats, Game.TYPE.ARCHER, Game.CONTROL.AI)
		if !dialogue:
			dialogue = Dialogue.new()
		if !recruit_dialogue:
			recruit_dialogue = Dialogue.new()
		stats.connect("class_changed", self, "set_sprite")
		print(stats.character_class)
		stats.character_class = Game.TYPE.ARCHER
		call_deferred("set_sprite")

func _init():
	add_to_group("ai_spawn")
#	print(stats)
#	if !stats:
#		print("Corrupt spawn in init!")
#	else:
#		print(stats)

func _ready():
	add_to_group("ai_spawns")
#	print(stats)
#	if stats is CharacterStats:
#		print("This is character stats")
#	else:
#		print("Wrong resource type!")
#	if !stats:
#		print("Corrupt spawn in ready!")
#	print(stats == self.stats, stats, self.stats)
#	print(stats.hp)

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
	
