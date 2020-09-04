extends Sprite

signal trigger

export(String) var dialogue_id
#export(int, "Interact", "Move") var trigger_type

var tile = Vector2(0, 0)
var is_trigger = true
var is_loot = false
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tile.x = floor(position.x / Game.cell_size)
	tile.y = floor(position.y / Game.cell_size)
#	print(tile)
	hide()

func use():
	print("use trigger ", dialogue_id)
	emit_signal("trigger", dialogue_id)
