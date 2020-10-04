extends Spatial

var tile = Vector3(0, 0, 0)

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
	TT.TYPE.ARCHER: "bow",
	TT.TYPE.MAGE: "wand",
	TT.TYPE.FIGHTER: "sword"
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func teleport(x, y):
	tile.x = round(x)
	tile.z = round(y)
	tile.y = 0.1
	translation.x = tile.x
	translation.z = tile.z
	translation.y = 0.1
	print("Chest ", translation)

func open(type):
	if empty:
		return
	start = OS.get_ticks_msec()
	start_y = $drop.position.y
	empty = true
	var loot = Item.new()
	loot.generate(item_spawner.level, item_spawner.equipment_slot, type)
#	play("open")
	$open.play()
	$drop.play(item_types[type])
	$drop.show()
	return loot

func loot():
	looted = true;
	$drop.hide()

func _process(_delta):
	if empty and !looted:
		var now = OS.get_ticks_msec()
		if now - start < ttl:
			$drop.translation.y = lerp(start_y, start_y - 8, float(now - start) / float(ttl))
		else:
			$drop.translation.y = start_y - 8
			yield(get_tree().create_timer(1.0), "timeout")
			$drop.hide()
#			get_parent().remove_child(self)?
