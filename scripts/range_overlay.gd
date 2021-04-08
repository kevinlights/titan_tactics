extends Spatial

onready var world = get_tree().get_root().get_node("World")
onready var cursorMode = 'default';
# cursorHighlights[option] = Array[Vector2(X,Z)]
var cursorHighlights = {
	'default': [Vector2(0, 0)],
	'thunder_storm': [
		Vector2(1,0),
		Vector2(-1,0),
		Vector2(0,1),
		Vector2(0,-1),
	],
	'flame_shower': [
		Vector2( 0, 0 ),
		Vector2( 1, 1 ),
		Vector2(-1, 1 ),
		Vector2(-1, -1),
		Vector2( 1, -1)
	],
	'sweeping_blow_north': [
		Vector2( -1, -1),
		Vector2( 0, -1),
		Vector2( 1, -1)
	],
	'sweeping_blow_south': [
		Vector2( -1, 1),
		Vector2( 0, 1),
		Vector2( 1, 1)
	],
	'sweeping_blow_west': [
		Vector2( -1, -1),
		Vector2( -1, 0),
		Vector2( -1, 1)
	],
	'sweeping_blow_east': [
		Vector2( 1, -1),
		Vector2( 1, 0),
		Vector2( 1, 1)
	]
}
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
				gridmap.set_tile_overlay(hint_tile, 'placeholder')
	hint_tile = tile
	
func set_gridmap(_gridmap):
	gridmap = _gridmap

func set_selector(_selector):
	clear()
	paint()
	if _selector:
		selector = gridmap.world_to_map(_selector)
		paint_selector()

func paint_selector():
	if selector:
		var highlights = cursorHighlights[cursorMode]
		for highlight in highlights:
			var highlight_tile = selector + Vector3(highlight.x, 0, highlight.y)
			var possible_tiles = gridmap.overlay.filter_tiles(highlight_tile.x, highlight_tile.z)
			if possible_tiles.size() == 1:
				var tile_overlay_success = gridmap.set_tile_overlay(possible_tiles[0], 'select')
				if tile_overlay_success == true:
					overlayed_tiles.push_back(possible_tiles[0])

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
		'cursor':  null,
		'move_distance': character.turn_limits.move_distance,
		'actions': character.turn_limits.actions,
		'atk_range': character.atk_range, # + character.item_atk.attack_range,
	}
	var select = world.get_node_or_null('select')
	if select: 
		_data.cursor = select.tile
	if data != _data:
		# this produces way too much output
#		print('range_overlay, data has changed ', _data)
		data = _data
		if data.actions > 0 or data.move_distance > 1:
			show()
		else:
			hide()

func _process(_time):
	if gridmap and origin:
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
		gridmap.set_tile_overlay(tile, 'placeholder')
	gridmap.overlay.blank_gridmap()
	overlayed_tiles = []

func hide():
	self.visible = false
	clear()

func show():
	clear()
	self.visible = true
	paint()

func paint():
	if not data:
		return
	for tile in gridmap.get_tiles_within(data.tile, data.move_distance - 1 + data.atk_range):
		var context_tile = Vector3(tile.x, 0, tile.z)
		var context = world.get_current_context(context_tile)
		
		var tile_overlay_success;
		if context == TT.CONTEXT.ATTACK and data.actions > 0 and world.get_current().can_move_and_attack_tile(tile):
			var target = world.entity_at(tile)
			if target and !target.is_loot and !target.is_trigger and target.character.control == TT.CONTROL.AI:
				tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
		elif context == TT.CONTEXT.MOVE:
			tile_overlay_success = gridmap.set_tile_overlay(tile, 'move')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(tile)
	
	if hint_tile:
		var tile_overlay_success = gridmap.set_tile_overlay(hint_tile, 'select')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(hint_tile)
		else:
			print_debug("Failed to render hint overlay")
	
