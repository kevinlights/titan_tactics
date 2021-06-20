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
var dialogue

var item_types = {
	TT.TYPE.ARCHER: "archer",
	TT.TYPE.MAGE: "mage",
	TT.TYPE.FIGHTER: "swordsman",
	TT.TYPE.QUEST: "key"
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func teleport(x, y, z):
	tile.x = round(x)
	tile.z = round(z)
	tile.y = y + 0.1
	translation.x = tile.x
	translation.z = tile.z
	translation.y = tile.y
	print("Chest ", translation)

func open(type):
	if empty:
		return
	start = OS.get_ticks_msec()
	start_y = $drop.translation.y
	empty = true
	var loot = Item.new()
	loot.generate(item_spawner.level, item_spawner.equipment_slot, type)
#	play("open")
	$open.play()
	$chest.hide()
	$openchest.show()
	$drop.play(item_types[type])
#	$drop.show()
	return loot

func loot():
	looted = true;
	$drop.hide()

func _process(_delta):
	if empty and !looted:
		var now = OS.get_ticks_msec()
		if now - start < ttl:
			$drop.translation.y = lerp(start_y, start_y + 0.5, float(now - start) / float(ttl))
		else:
			$drop.translation.y = start_y + 0.5
			yield(get_tree().create_timer(4.0), "timeout")
			$drop.hide()
#			get_parent().remove_child(self)?
