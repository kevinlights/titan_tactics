tool
class_name PlayerSpawner
extends Sprite3D

func init():
	axis = 1
	pixel_size = 0.06
	translation.y = 0.2
	centered = false
	texture = load("res://gfx/playerspawn_map.png")
	add_to_group("player_spawns") # so world can find it
	if not Engine.editor_hint:
		hide()

func _enter_tree():
	init()

func _ready():
	init()
