extends Spatial

onready var materials = {
	"move": preload("res://gfx/range-overlay/move_range_shader.material"),
	"attack": preload("res://gfx/range-overlay/attack_range_shader.material"),
}


onready var world = get_tree().get_root().get_node("World")
var origin setget set_origin
var gridmap setget set_gridmap
func set_gridmap(_gridmap):
	gridmap = _gridmap

func set_origin(_origin):
	origin = _origin
	if _origin:
		show() 
	else:
		hide()
	
func _ready():
	pass

func _process(time):
	if gridmap and origin:
		if self.visible:
			var shouldHide = (origin.movement.moving) or (world.current_turn == TT.CONTROL.AI or world.get_current_context(origin.tile) == TT.CONTEXT.NOT_PLAYABLE)
			if shouldHide:
				hide()
		else:
			var shouldShow = (not origin.movement.moving) and (world.current_turn == TT.CONTROL.PLAYER) and (world.get_current_context(origin.tile) == TT.CONTEXT.GUARD)
			if shouldShow:
				show()

func clear():
	for child in get_children():
		child.queue_free()

func drawSqaure(location, material):
	var square = CSGBox.new()
	square.set_depth(0.75)
	square.set_height(0.9)
	square.set_width(0.9)
	square.translate(Vector3(location.x + 0.05, location.y, location.z + 0.05))
	square.set_material(material)
	add_child(square)

func hide():
	self.visible = false

func show():
	clear()
	self.visible = true
	var move_distance = origin.character.turn_limits.move_distance
	var tiles = gridmap.get_tiles_within(origin.tile, move_distance - 1)
	clear()
	for tile in tiles:
		var context_tile = Vector3(tile.x, 0, tile.z)
		var context = world.get_current_context(context_tile)
		if context == TT.CONTEXT.ATTACK:
			drawSqaure(tile, materials.attack)
		elif context == TT.CONTEXT.MOVE:
			drawSqaure(tile, materials.move)
