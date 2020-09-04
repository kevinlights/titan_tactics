extends AnimatedSprite

var tile = Vector2(0, 0)
var cell_size = 16
var loot = Item.new()
var empty = false
var looted = false
var is_loot = true
var is_dead = false
var is_trigger = false

# to animate loot
var start
var start_y = 0
var ttl = 400

var item_spawner

var item_types = {
	Game.TYPE.ARCHER: "bow",
	Game.TYPE.MAGE: "wand",
	Game.TYPE.FIGHTER: "sword"
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func teleport(x, y):
	tile.x = x
	tile.y = y
	position.x = x * cell_size
	position.y = y * cell_size

func open(type):
	if empty:
		return
	start = OS.get_ticks_msec()
	start_y = $drop.position.y
	empty = true
	loot.generate(item_spawner.level, item_spawner.equipment_slot, type)
	play("open")
	$open.play()
	$drop.play(item_types[type])
	$drop.show()
	return loot

func loot():
	looted = true;
	$drop.hide()

func _process(delta):
	if empty and !looted:
		var now = OS.get_ticks_msec()
		if now - start < ttl:
			$drop.position.y = lerp(start_y, start_y - 8, float(now - start) / float(ttl))
		else:
			$drop.position.y = start_y - 8
			yield(get_tree().create_timer(1.0), "timeout")
			$drop.hide()
#			get_parent().remove_child(self)?
