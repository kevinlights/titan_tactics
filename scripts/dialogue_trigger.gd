extends Sprite

export(String) var dialogue_id
export(int, "Interact", "Move") var trigger_type

var tile = Vector2(0, 0)
var is_trigger = true
var is_loot = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tile.x = round(position.x / Game.cell_size)
	tile.y = round(position.y / Game.cell_size)
#	hide()
