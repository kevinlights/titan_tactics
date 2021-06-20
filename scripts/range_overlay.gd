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
		if cursorMode == 'default':
			var target = world.entity_at(selector)
			if target and !target.is_loot and !target.is_trigger and target.character:
				if origin and origin == target:
					return
				clear_except(selector)
				highlight_target_range(target, selector)

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
	
func clear_except(remain_tile):
	var remaining_overlayed_tiles = []
	for tile in overlayed_tiles:
		if remain_tile.x == tile.x and remain_tile.z == tile.z:
			remaining_overlayed_tiles.push_back(tile)
		else:
			gridmap.set_tile_overlay(tile, 'placeholder')
	overlayed_tiles = remaining_overlayed_tiles

func hide():
	self.visible = false
	clear()

func show():
	clear()
	self.visible = true
	paint()

func paint():
	if not data or not origin:
		return
	print(origin.character.turn_limits)
	highlight_target_range(origin, data.tile)
	if hint_tile:
		var tile_overlay_success = gridmap.set_tile_overlay(hint_tile, 'select')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(hint_tile)
		else:
			print_debug("Failed to render hint overlay")

func highlight_target_range(target, starting_tile):
	#print(target)
	var mov_range = target.character.turn_limits.move_distance
	if target.character.turn_limits.move_actions == 0:
		mov_range = 0
	elif mov_range > 0:
		mov_range -= 1
	var atk_range = target.character.atk_range
	print('target ', mov_range, ' - ', atk_range)
	var blocked_cells = world.get_blocked_cells()
	if world.mode == world.MODE.CHECK_MAP or world.current_turn != target.character.control:
		mov_range = max(target.character.mov_range - 1, 0)
	for tile in gridmap.get_tiles_within(starting_tile, mov_range + atk_range * 2):
		var mov_distance = abs(starting_tile.x - tile.x) + abs(starting_tile.z - tile.z)
		var path_to_tile = world.pathfinder.find_path(starting_tile, tile, blocked_cells)
		if path_to_tile.size() == 0:
			continue
		var tile_overlay_success;
		if mov_distance <= mov_range:
			var cell_target = world.entity_at(tile)
			# path to walk is longer than expected due to unpassable tiles
			if path_to_tile.size() > mov_range + 1:
				# as movement is not diagonal but attacks can be, need to compute atk_distance
				# from the edge of mov_range
				var potential_atk_start = path_to_tile[mov_range]
				var atk_distance = Vector2(potential_atk_start.x, potential_atk_start.z).distance_to(Vector2(tile.x, tile.z))
				
				if atk_range == 1:
					if atk_distance <= atk_range:
						tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
				elif floor(atk_distance) <= atk_range:
					tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
			else: 
				if cell_target and !cell_target.is_loot and !cell_target.is_trigger and cell_target.character and cell_target.character.control != target.character.control:
					tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
				elif cell_target and !cell_target.is_loot and !cell_target.is_trigger and cell_target.character and cell_target.character.control == target.character.control:
					continue
				else:
					tile_overlay_success = gridmap.set_tile_overlay(tile, 'move')
		else:
			# as movement is not diagonal but attacks can be, need to compute atk_distance
			# from the edge of mov_range
			var potential_atk_start = path_to_tile[mov_range]
			var atk_distance = Vector2(potential_atk_start.x, potential_atk_start.z).distance_to(Vector2(tile.x, tile.z))
			if atk_range == 1:
				if atk_distance <= atk_range:
					tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
			elif floor(atk_distance) <= atk_range:
				tile_overlay_success = gridmap.set_tile_overlay(tile, 'attack')
		if tile_overlay_success == true:
			overlayed_tiles.push_back(tile)
