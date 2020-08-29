class_name ChestSpawner
extends Sprite
tool

export(Resource) var item_spawner

func _enter_tree():
	if Engine.editor_hint:
		texture = load("res://gfx/chest_icon.png")
		if !item_spawner:
			print("create stats object")
			item_spawner = ItemSpawner.new()

func _init():
	add_to_group("chest_spawns")

func _ready():
	add_to_group("chest_spawns")
