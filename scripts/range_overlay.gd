extends Spatial

onready var materials = {
	"move": preload("res://gfx/range-overlay/move.material"),
	"attack": preload("res://gfx/range-overlay/attack.material"),
}


onready var world = get_tree().get_root().get_node("World")
var overlayed_tiles = []
var data
var origin setget set_origin
var gridmap setget set_gridmap
var hint_tiles = []

func add_hint_tile(tile):
	hint_tiles.push_back(tile)
	
func set_gridmap(_gridmap):
	gridmap = _gridmap

func set_origin(_origin):
	origin = _origin
	if _origin:
		generate_data(origin) 
	else:
		hide()
	
func _ready():
	pass
	
func generate_data(origin):
	var character = origin.character;
	var _data = {
		'tile': origin.tile,
		'move_distance': character.turn_limits.move_distance,
		'actions': character.turn_limits.actions,
		'atk_range': character.atk_range + character.item_atk.attack_range,
	}
	if data != _data:
		data = _data
		if data.actions > 0 or data.move_distance > 1:
			show()
		else:
			hide()

func _process(time):
	if gridmap and origin:
		#print(self.visible, data, origin.movement.moving, origin.tile)
		if self.visible:
			var shouldHide = (origin.movement.moving) or (world.current_turn == TT.CONTROL.AI or world.get_current_context(origin.tile) == TT.CONTEXT.NOT_PLAYABLE)
			if shouldHide:
				hide()
			if not origin.movement.moving and origin.tile != data.tile:
				generate_data(origin)
		else:
			var shouldShow = (not origin.movement.moving) and (world.current_turn == TT.CONTROL.PLAYER) and (world.get_current_context(origin.tile) == TT.CONTEXT.GUARD)
			if shouldShow:
				generate_data(origin)

func clear():
	for tile in overlayed_tiles:
		gridmap.set_tile_overlay(tile, '')
	overlayed_tiles = []
	for child in get_children():
		child.queue_free()

func drawSqaure(location, material):
	var square = CSGBox.new()
	square.set_depth(0.9)
	square.set_height(0.9)
	square.set_width(0.9)
	square.translate(Vector3(location.x + 0.05, location.y, location.z + 0.05))
	square.set_material(material)
	add_child(square)

func hide():
	self.visible = false
	clear()

func show():
	if not data:
		return
	clear()
	self.visible = true
	
	for tile in gridmap.get_tiles_within(data.tile, data.move_distance - 1):
		var context_tile = Vector3(tile.x, 0, tile.z)
		var context = world.get_current_context(context_tile)
		
		var tile_overlay_success;
		if context == TT.CONTEXT.ATTACK and data.actions > 0:
			pass # TODO: include if/when implementing psuedo range for melee
			#tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
		elif context == TT.CONTEXT.MOVE:
			tile_overlay_success = gridmap.set_tile_overlay(tile, 'move')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(tile)
		elif tile_overlay_success == false:
			# TODO: implement fallback using previous approach to handle bridges etc
			print ('tile_overlay failed for ', tile)
			if context == TT.CONTEXT.ATTACK:
				drawSqaure(tile, materials.attack)
			elif context == TT.CONTEXT.MOVE:
				drawSqaure(tile, materials.move)
	
	for tile in gridmap.get_tiles_within(data.tile, data.atk_range):
		var context_tile = Vector3(tile.x, 0, tile.z)
		var context = world.get_current_context(context_tile)
		
		var tile_overlay_success;
		if context == TT.CONTEXT.ATTACK:
			tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(tile)
		elif tile_overlay_success == false:
			# TODO: implement fallback using previous approach to handle bridges etc
			if context == TT.CONTEXT.ATTACK:
				drawSqaure(tile, materials.attack)
	
	for tile in hint_tiles:
		var tile_overlay_success = gridmap.set_tile_overlay(tile, 'hint')
		if not tile_overlay_success == true:
			print_debug("Failed to render hint overlay")
