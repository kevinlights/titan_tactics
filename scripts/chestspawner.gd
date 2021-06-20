class_name ChestSpawner
extends Sprite3D
tool

export(Resource) var item_spawner
export(Resource) var dialogue

func _enter_tree():
	axis = 1
#	pixel_size = 0.08
#	translation.y = 0.2
	pixel_size = 0.06
	translation.y = 0.2
	centered = false
	billboard = SpatialMaterial.BILLBOARD_DISABLED
#	texture = load("res://gfx/chest_icon.png")
#	add_to_group("story_markers") # so world can find it
	add_to_group("chest_spawns")
	if not Engine.editor_hint:
		translation.z -= 1
		hide()	
	else:
		texture = load("res://gfx/chest_icon.png")
		if !item_spawner:
			print("create stats object")
			item_spawner = ItemSpawner.new()

func _init():
	add_to_group("chest_spawns")

func _ready():
	add_to_group("chest_spawns")
