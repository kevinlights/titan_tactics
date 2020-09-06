tool
class_name DialogueTrigger
extends Sprite

signal trigger

export(String) var dialogue_id
export(String, "always", "level_complete") var available = "always"

var tile = Vector2(0, 0)
var is_trigger = true
var is_loot = false
var is_dead = false
var consumed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("characters") # so world can find it
	add_to_group("dialogue_triggers") # so level can find it
	tile.x = floor(position.x / Game.cell_size)
	tile.y = floor(position.y / Game.cell_size)
	if Engine.editor_hint:
		texture = load("res://gfx/speak_map.png")
	else:
		hide()

func use():
	consumed = true
	print("use trigger ", dialogue_id)
	emit_signal("trigger", dialogue_id)
