extends Spatial

onready var materials = {
	"move": preload("res://gfx/range-overlay/move.material"),
	"attack": preload("res://gfx/range-overlay/attack.material"),
	"select": preload("res://gfx/range-overlay/select.material"),
	"hint": preload("res://gfx/range-overlay/hint.material"),
}


onready var world = get_tree().get_root().get_node("World")
var overlayed_tiles = []
var data
var origin setget set_origin
var gridmap setget set_gridmap
var selector setget set_selector
var hint_tile

func set_hint_tile(tile):
	if hint_tile:
		if overlayed_tiles.find(hint_tile) > -1:
			var context_tile = Vector3(hint_tile.x, 0, hint_tile.z)
			var context = world.get_current_context(context_tile)
			if context == TT.CONTEXT.MOVE:
				gridmap.set_tile_overlay(hint_tile, 'move')
			elif context == TT.CONTEXT.ATTACK:
				gridmap.set_tile_overlay(hint_tile, 'attack')
			else:
				gridmap.set_tile_overlay(hint_tile, '')
		else:
			gridmap.set_tile_overlay(hint_tile, '')
	hint_tile = tile
	
func set_gridmap(_gridmap):
	gridmap = _gridmap

var selectedCube = null
var origCube = null
func set_selector(_selector):
	if selector:
#		if selectedCube:
#			if has_node(selectedCube.name):
#				remove_child(selectedCube)
#			if origCube:
#				print('add_child(origCube)', origCube)
#				add_child(origCube)
#				origCube = null
#			selectedCube = null
		if overlayed_tiles.find(selector) > -1:
			var context_tile = Vector3(selector.x, 0, selector.z)
			var context = world.get_current_context(context_tile)
			if context == TT.CONTEXT.MOVE:
				if hint_tile and hint_tile.x == selector.x and hint_tile.z == selector.z:
					gridmap.set_tile_overlay(selector, 'hint')
				else:
					gridmap.set_tile_overlay(selector, 'move')
			elif context == TT.CONTEXT.ATTACK:
				gridmap.set_tile_overlay(selector, 'attack')
			else:
				gridmap.set_tile_overlay(selector, '')
		else:
			gridmap.set_tile_overlay(selector, '')
	var map_selector = gridmap.world_to_map(_selector)
	var possible_selected_tiles = gridmap.filter_tiles(map_selector.x, map_selector.z)
	if possible_selected_tiles.size() == 1:
		selector = gridmap.point_to_world(possible_selected_tiles[0], false)
		var tile_overlay_success = gridmap.set_tile_overlay(selector, 'select')
		if not tile_overlay_success:
			selectedCube = drawSqaure(selector, materials.select)
			remove_child(selectedCube)
			for child in get_children():
				if child.translation == selectedCube.translation:
					origCube = child
					remove_child(origCube)
			print('add_child(selectedCube)', selectedCube)
			add_child(selectedCube)

func set_origin(_origin):
	origin = _origin
	if _origin:
		generate_data(origin)
	else:
		hide()
	
func _ready():
	pass
	
func generate_data(new_origin):
	var character = new_origin.character;
	var _data = {
		'tile': new_origin.tile,
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

func _process(_time):
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
	print('add_child(square)', square)
	add_child(square)
	return square

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
	
	if hint_tile:
		var tile_overlay_success = gridmap.set_tile_overlay(hint_tile, 'hint')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(hint_tile)
		else:
			print_debug("Failed to render hint overlay")
