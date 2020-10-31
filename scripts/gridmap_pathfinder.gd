extends GridMap

onready var astar := AStar.new()
onready var tiles := []

onready var counts := {
	'connections': 0,
	'passable_tiles': 0,
	'impassable_tiles': 0,
	'structure_tiles': 0,
	'decoration_tiles': 0,
	'excluded_tiles': 0,
}
var debug := false # change to true to increase logging
var debug_path := false # change to true to increase logging
var hide_non_walkable_tiles := false # change to true to visually debug
var no_diagonal_movement := true # change to false to allow diagonal movement

# decorations are impassable to the player.
var decorations := ["Tree", "stump", "Water", "underwater", "waterside", 'wall', 'wall1', 'wallcorner1001', 'wallcorner1003', 'rock_02', 'wall_02', 'wall_corner_02_shadow', 'wall_corner_02_light', 'pillar', 'Palm Tree', 'Stalagmite', 'crystal000', 'rock_03', 'wall_03', 'wall_corner_03_shadow', 'wall_corner_03_light', 'pillar']

# structures are normally larger than a single tile and require custom logic to join tiles
var structures := ['Smallbridge', 'Bridge']
var multi_tile_objects := ['house1', 'house_02', 'house_03', 'tree', 'cristal005']

# Cardinals
# nw, n, ne
# w ,  , e
# sw, s, se 
# cardinalHeights are only needed for walkable nodes that join up.
# structures such as bridges with custom logic need to be added above and manually implemented in _connect_structures.
var cardinalHeights := { # y_deltas
	# tile_type: [NW, N, NE, E, SE, S, SW, W]
	'Low cube': [1, 1, 1, 1, 1, 1, 1, 1],
	'marble': [1, 1, 1, 1, 1, 1, 1, 1],
	'marblediamond': [1, 1, 1, 1, 1, 1, 1, 1],
	'deck': [1, 1, 1, 1, 1, 1, 1, 1],
	'Cube': [2, 2, 2, 2, 2, 2, 2, 2],
	'block_02': [2, 2, 2, 2, 2, 2, 2, 2],
	'ground_03': [2, 2, 2, 2, 2, 2, 2, 2],
	'Ramp': [2, 2, 2, 1.5, 1, 1, 1, 1.5],
	'steps': [1, 0.5, 0, 0, 0, 0.5, 1, 1],
	'stairs': [1, 1, 1, 0.5, 0, 0, 0, 0.5],
	'Ramp corner': [2, 1.5, 1, 1, 1, 1, 1, 1.5],
}
var cardinalDeltas := [
	# Vector2(x_delta, z_delta)
	Vector2(-1, -1), # NW
	Vector2(0, -1), # N
	Vector2(1, -1), # NE
	Vector2(1, 0), # E
	Vector2(1, 1), # SE
	Vector2(0, 1), # S
	Vector2(-1, 1), # SW
	Vector2(-1, 0), # W
]

# these are computed internally and are different depending on what axis it is rotated on.
# this file currently only expects x axis rotation and doesn't support others.
var orientationModifier := {
	0: 0,
	22: 6, # 90 deg,
	10: 4, # 180 deg,
	16: 2, # 270/-90 deg
}

# eg. should be connected cases.
# low cube on level 1 (1,1,1,1), next to a cube on level 0 (2,2,2,2).
# a ramp corner (2,1,1,1) diagnally next to a cube (2,2,2,2) on the same level should match if going 2->2.

# Assumptions:
# points are all connected biderectionally.

# Notes:
# internally each tile corresponds to 1 cell, though the tile itself my span outside of its unit square.
# most points cooresponds to a non-impassable cell, these are stored in an array and their index = the point id.
# z is horizontal (east/west)
# x is vertical (north/south)
# y is level

# TODOs:
# implement custom logic to connect bridges.
# hardcode additional cardinalHeights as necessary.

# Thoughts:
# should diagonal movement have a higher 'cost' as it has a higher distance? 
onready var ml_mapping = {}
func _ready():
	_init_overlayed_tiles()
	_init_astar()
	
func _init_overlayed_tiles():
	var item_ids = mesh_library.get_item_list()
	for item_id in item_ids:
		var name = mesh_library.get_item_name(item_id)
		if cardinalHeights.has(name):
			ml_mapping[name] = {
				'_': item_id,
			}

func generate_overlay_tile(name, item_id, type):
	# type = move / attack / hint / select
	var type_key = '_' + type;
	if ml_mapping.has(name):
		if not ml_mapping[name].has(type_key):
			var mesh = mesh_library.get_item_mesh(item_id)
			var mesh_dup = mesh.duplicate()
			var material = mesh.surface_get_material(0).duplicate()
			material.set_next_pass(load("res://gfx/range-overlay/inset_"+ type + ".material"))
			mesh_dup.surface_set_material (0, material)
			
			var id = mesh_library.get_last_unused_item_id() + 1
			mesh_library.create_item(id)
			mesh_library.set_item_mesh(id, mesh_dup)
			mesh_library.set_item_name(id, name + type_key)
			ml_mapping[name][type_key] = id
		return true
	else:
		return false
	
func world_path(path:PoolVector3Array):
	var w_path = PoolVector3Array()
	for point in path:
		w_path.append(point_to_world(point, false))
	return w_path

func point_to_world(point: Vector3, exclude_y: bool):
	var offset = get_parent().translation + Vector3(-0.5, -1, -0.5)
	offset.y = 0
	var y = 0 if exclude_y else (point.y / 2)
	return map_to_world(point.x, y, point.z) + offset

func find_path(start, end, blocked_cells = []):
	var offset = get_parent().translation * -1
	if debug_path:
		print("end ", end)
	var map_end = world_to_map(end)
	if debug_path:
		print("end map ", map_end)
		print("back to world end ", map_to_world(map_end.x, map_end.y, map_end.z))
		print("find_path ", start, end)
	start = world_to_map(start + offset)
	end = world_to_map(end + offset)
	if debug_path:
		print("find_path (grid coordinates) ", start, end)
	var possible_starts = filter_tiles(start.x, start.z)
	var possible_ends = filter_tiles(end.x, end.z)
	if possible_starts.size() == 1 and possible_ends.size() == 1:
		var start_id = vector_to_id(possible_starts[0])
		var end_id = vector_to_id(possible_ends[0])		
		
		var blocked_tile_ids = []
#		print(start, end, blocked_cells)
		if(blocked_cells.size() > 0):
			for blocked_cell in blocked_cells:
				for tile in filter_tiles(blocked_cell.x, blocked_cell.z):
					var blocked_id = vector_to_id(tile)
					if blocked_id != start_id and blocked_id != end_id:
						blocked_tile_ids.push_back(blocked_id)
		for id in blocked_tile_ids:
			astar.set_point_disabled(id, true)
		var path = astar.get_point_path(start_id, end_id)
		for id in blocked_tile_ids:
			astar.set_point_disabled(id, false)
		var w_path = world_path(path)
		if debug_path:
			print("found_path ", path)
			print("found_path (world) ", w_path)
		return w_path
	elif possible_starts.size() == 0 or possible_ends.size() == 0:
		print('Unable to find a possible start/end tile for pathfinding ', possible_starts, possible_ends)
	elif possible_starts.size() > 1 or possible_ends.size() > 1:
		print_debug("Multiple possible start/end tiles found for pathfinding")
	return []

onready var world_to_tile_map = {}
func get_tiles_within(_start, distance):
	var offset = get_parent().translation * -1
	var start = world_to_map(_start + offset)
	var possible_starts = filter_tiles(start.x, start.z)
	if possible_starts.size() == 1:
		var start_id = vector_to_id(possible_starts[0])
		var output_ids = []
		var start_ids = [start_id]
		for i in range(0, distance):
			var next_ids = []
			for id in start_ids:
				for next in astar.get_point_connections(id):
					if next != start_id and output_ids.find(next) == -1:
						output_ids.push_back(next)
						next_ids.push_back(next)
				start_ids = next_ids
		var output_points = []
		for id in output_ids:
			var world_point = point_to_world(astar.get_point_position(id), false)
			if not world_to_tile_map.has(world_point):
				world_to_tile_map[world_point] = id
			output_points.push_back(world_point)
		return output_points
	else:
		return []

func set_tile_overlay(world_point, type):
	if not world_to_tile_map.has(world_point):
		var local_point = world_to_map(world_point)
		var possible_tiles = filter_tiles(local_point.x, local_point.z)
		if possible_tiles.size() == 1:
			var tile_id = tiles.find(possible_tiles[0])
			world_to_tile_map[world_point] = tile_id
	if world_to_tile_map.has(world_point):
		var tile_id = world_to_tile_map[world_point]
		var cell = astar.get_point_position(tile_id)
		var item_id = get_cell_item(cell.x, cell.y, cell.z)
		var name = get_cell_name(cell).replace('_move', '').replace('_attack', '').replace('_hint', '').replace('_select', '')
		if type != '':
			generate_overlay_tile(name, item_id, type)
		
		var type_key = '_' + type;
		if ml_mapping.has(name) and ml_mapping[name].has(type_key):
			var new_item_id = ml_mapping[name][type_key]
			var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
			set_cell_item(cell.x, cell.y, cell.z, new_item_id, orientation)
			return true
	return false

func vector_to_id(vector):
	return tiles.find(vector)
	
func filter_tiles(x, z):
	var output = []
	for tile in tiles:
		if(tile and tile.x == x and tile.z == z):
			output.push_back(tile)
	return output

func _init_astar():
	var ground_cells = get_used_cells()
	var iterated_types = []
	var structure_tiles = []
	var multi_tiles = []
	for cell in ground_cells:
		var name = get_cell_name(cell)
		if decorations.find(name) != -1:
			counts.decoration_tiles += 1
			continue
		if multi_tile_objects.find(name) != -1:
			multi_tiles.push_back(cell)
			counts.decoration_tiles += 1
			continue			
		if structures.find(name) != -1:
			# TODO: add to array and manually connect after.
			counts.structure_tiles += 1
			structure_tiles.push_back(cell)
			continue
		
		if !iterated_types.has(name):
			iterated_types.append(name)
			if not cardinalHeights.has(name):
				print_debug("Missing cardinal heights for '", name, "' type. Excluding all occurances from walkable tiles.")
		
		if cardinalHeights.has(name):
			var max_height = cell.y + cardinalHeights[name].max()
			var exclude = false
			for level in range(cell.y, max_height + 1):
				if (get_cell_item(cell.x, level + 1, cell.z) != GridMap.INVALID_CELL_ITEM):
					counts.impassable_tiles += 1
					if debug:
						print('excluding "', name, '" ', cell, ' as it has a tile above')
					exclude = true
					break
			if not exclude:
				var cell_height = cell.y + _compute_avg_height(name)
				astar.add_point(tiles.size(), cell, min(1, cell_height))
				if debug:
					print('adding "', name, '" ', cell, ' as tile #', tiles.size())
				tiles.push_back(cell)
				counts.passable_tiles += 1
			else:
				counts.excluded_tiles += 1
		else:
			counts.excluded_tiles += 1
	# Code to remove cells below multi tiled structures from passable_tiles
	for cell in multi_tiles:
		var name = get_cell_name(cell)
		var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
		var orientation_modifier = {
			0: 0,
			22: 2,
			10: 4,
			16: 6,
		}[orientation]
		var directions = []
		match name:
			'tree':
				directions = [
					cardinalDeltas[(7 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(1 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(3 + orientation_modifier) % cardinalDeltas.size()],
				]
			'cristal005':
				# NOTE: assuming identical behaviour with tree
				directions = [
					cardinalDeltas[(7 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(1 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(3 + orientation_modifier) % cardinalDeltas.size()],
				]
			'house1':
				directions = [
					cardinalDeltas[(3 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(5 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(7 + orientation_modifier) % cardinalDeltas.size()],
				]
			'house_02':
				# NOTE: assuming identical behaviour with house1
				directions = [
					cardinalDeltas[(3 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(5 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(7 + orientation_modifier) % cardinalDeltas.size()],
				]
			'house_03':
				# NOTE: assuming identical behaviour with house1
				directions = [
					cardinalDeltas[(3 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(5 + orientation_modifier) % cardinalDeltas.size()],
					cardinalDeltas[(7 + orientation_modifier) % cardinalDeltas.size()],
				]
		var cell_to_remove = Vector3(cell.x, cell.y - 1, cell.z)				
		for delta in directions:
			cell_to_remove.x += delta.x
			cell_to_remove.z += delta.y
			var idx = tiles.find(cell_to_remove)
			print(idx)
			if idx > -1:
				tiles[idx] = null
				counts.impassable_tiles += 1
				counts.passable_tiles -= 1
		cell_to_remove = Vector3(cell.x, cell.y - 2, cell.z)
		for delta in directions:
			cell_to_remove.x += delta.x
			cell_to_remove.z += delta.y
			var idx = tiles.find(cell_to_remove)
			print(idx)
			if idx > -1:
				tiles[idx] = null
				counts.impassable_tiles += 1
				counts.passable_tiles -= 1
	_connect_points()
	_connect_structures(structure_tiles)
	
	if hide_non_walkable_tiles:
		for cell in ground_cells:
			var cell_id = vector_to_id(cell)
			if cell_id == -1:
				set_cell_item(cell.x, cell.y, cell.z, INVALID_CELL_ITEM)
			else:
				var connections = astar.get_point_connections(cell_id)
				if connections.size() == 0:
					set_cell_item(cell.x, cell.y, cell.z, INVALID_CELL_ITEM)
	print(counts)

func _compute_avg_height(name):
	var heights = cardinalHeights[name]
	if heights:
		var sum = 0
		for val in heights:
			sum += val
		return sum / heights.size()
	else:
		return 0

func _connect_points():
	for cell in tiles:
		if not cell:
			continue
		var neighbours = _get_neighbors(cell)
		for neighbour in neighbours:
			_connect_cells(cell, neighbour)

func _connect_cells(a_cell, b_cell, upsert = false):
	if no_diagonal_movement:
		if abs(a_cell.x - b_cell.x) + abs(a_cell.z - b_cell.z) > 1:
			return
	var a_id = vector_to_id(a_cell)
	var b_id = vector_to_id(b_cell)
	if upsert:
		if a_id == -1:
			a_id = tiles.size()
			astar.add_point(a_id, a_cell)
			tiles.push_back(a_cell)
		if b_id == -1:
			b_id = tiles.size()
			astar.add_point(b_id, b_cell)
			tiles.push_back(b_cell)
	if a_id > -1 and b_id > -1:
		_connect_ids(a_id, b_id)

func _connect_ids(a_id, b_id):
	if not astar.are_points_connected (a_id, b_id):
		if debug:
			print("connecting cells (", a_id, ',', b_id, ')')
		astar.connect_points(a_id, b_id)
		counts.connections += 1
				
func _connect_structures(cells):
	var deltaMappings = {
		'Smallbridge': {
			0: cardinalDeltas[7],
			22: cardinalDeltas[1], # 90 deg,
			10: cardinalDeltas[3], # 180 deg,
			16: cardinalDeltas[5], # 270/-90 deg
		},
		'Bridge': {
			0: cardinalDeltas[7],
			22: cardinalDeltas[1], # 90 deg,
			10: cardinalDeltas[3], # 180 deg,
			16: cardinalDeltas[5], # 270/-90 deg
		}
	}
	for cell in cells:
		var name = get_cell_name(cell)
		var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
		
		match name:
			'Bridge':
				var cardinalDelta = deltaMappings[name][orientation]
				
				var before_cell = null
				for y in range(cell.y, cell.y - 3, -1):
					before_cell = Vector3(cell.x + cardinalDelta.x * 2, y, cell.z + cardinalDelta.y * 2)
					if (get_cell_item(before_cell.x, before_cell.y, before_cell.z) == GridMap.INVALID_CELL_ITEM):
						before_cell = null
					else:
						var before_cell_name = get_cell_name(before_cell)
						break
				if before_cell == null:
					print_debug("Can't find before tile of Bridge ", cell)
					
				var bridge_tile = null
				for mult in range(1, 4):
					var prev_tile = bridge_tile
					if prev_tile == null:
						prev_tile = before_cell
					bridge_tile = Vector3(prev_tile.x - cardinalDelta.x, cell.y, prev_tile.z - cardinalDelta.y)
					_connect_cells(prev_tile, bridge_tile, true)
					
				# TODO: not working for 0 degree orientation
				var after_cell = null
				for y in range(cell.y, cell.y - 3, -1):
					after_cell = Vector3(bridge_tile.x - cardinalDelta.x, y, bridge_tile.z - cardinalDelta.y)
					if (get_cell_item(after_cell.x, after_cell.y, after_cell.z) == GridMap.INVALID_CELL_ITEM):
						after_cell = null
					else:
						break
				if after_cell == null:
					print_debug("Can't find after tile of Bridge ", cell)
				
				if before_cell and after_cell:
					_connect_cells(before_cell, cell, true)
					_connect_cells(bridge_tile, after_cell, true)
			'Smallbridge':
				var cardinalDelta = deltaMappings[name][orientation]
				var before_cell = null
				for y in range(cell.y, cell.y - 3, -1):
					before_cell = Vector3(cell.x + cardinalDelta.x, y, cell.z + cardinalDelta.y)
					if (get_cell_item(before_cell.x, before_cell.y, before_cell.z) == GridMap.INVALID_CELL_ITEM):
						before_cell = null
					else:
						break
				if before_cell == null:
					print_debug("Can't find before tile of Smallbridge ", cell)
					
				var bridge_tile = null
				for mult in range(1, 2):
					var prev_tile = bridge_tile
					if prev_tile == null:
						prev_tile = cell
					bridge_tile = Vector3(cell.x - cardinalDelta.x * mult, cell.y, cell.z - cardinalDelta.y * mult)
					_connect_cells(prev_tile, bridge_tile, true)
					
				# TODO: not working for 0 degree orientation
				var after_cell = null
				for y in range(cell.y, cell.y - 3, -1):
					after_cell = Vector3(bridge_tile.x - cardinalDelta.x, y, bridge_tile.z - cardinalDelta.y)
					if (get_cell_item(after_cell.x, after_cell.y, after_cell.z) == GridMap.INVALID_CELL_ITEM):
						after_cell = null
					else:
						break
				if after_cell == null:
					print_debug("Can't find after tile of Smallbridge ", cell)
				
				if before_cell and after_cell:
					_connect_cells(before_cell, cell, true)
					_connect_cells(bridge_tile, after_cell, true)
				# TODO: in between cells + after_cell
		

func _get_neighbors(cell):
	if not cell:
		return
	var neighbours = []
	# deltas = Vector2(x_delta, z_delta)
	for deltas in cardinalDeltas:
		var idx = cardinalDeltas.find(deltas)
		var expected_height = cell.y + get_cardinal_height(cell, idx)
		if expected_height == null:
			continue
		
		for level_delta in range(0, expected_height + 1):
			var neghbour = Vector3(cell.x + deltas.x, cell.y + level_delta, cell.z + deltas.y)
			if (get_cell_item(neghbour.x, neghbour.y, neghbour.z) == GridMap.INVALID_CELL_ITEM):
				continue
			var neighbour_height = get_cardinal_height(neghbour, idx + 4)
			#print(
			#	deltas, ' ',
			#	mesh_library.get_item_name(get_cell_item(cell.x, cell.y, cell.z)), 
			#	expected_height,
			#	', ',
			#	mesh_library.get_item_name(get_cell_item(neghbour.x, neghbour.y, neghbour.z)), 
			#	neighbour_height
			#)
			if neighbour_height == null:
				continue
			var computed_height = neghbour.y + get_cardinal_height(neghbour, idx + 4)
			if computed_height == expected_height:
				var neighbour_name = get_cell_name(neghbour)
				neighbours.push_back(neghbour)		
	return neighbours

func get_cardinal_height(cell, dir_idx):
	var name = get_cell_name(cell)
	
	if decorations.find(name) != -1 or structures.find(name) != -1 or multi_tile_objects.find(name) != -1:
		return null
	if not cardinalHeights.has(name):
		print_debug('Unexpected cell type. Assuming not walkable.')
		return null
	var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
	if orientation == -1:
		return null
	if not orientationModifier.has(orientation):
		print_debug('Unexpected orientation (', orientation, ') for cell (', cell, '). Assuming no neighbours.')
		return null
	return cardinalHeights[name][(dir_idx + orientationModifier[orientation]) % cardinalDeltas.size()]

func get_cell_name(cell):
	var itemId = get_cell_item(cell.x, cell.y, cell.z)
	var name = mesh_library.get_item_name(itemId)
	return name
