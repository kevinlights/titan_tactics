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
var hide_non_walkable_tiles := false # change to true to visually debug

# decorations are impassable to the player.
var decorations := ["Tree", "Water", "underwater", "waterside"]

# structures are normally larger than a single tile and require custom logic to join tiles
var structures := ['Smallbridge']

# Cardinals
# nw, n, ne
# w ,  , e
# sw, s, se 
var cardinalHeights := { # y_deltas
	# tile_type: [NW, N, NE, E, SE, S, SW, W]
	'Low cube': [1, 1, 1, 1, 1, 1, 1, 1],
	'Cube': [2, 2, 2, 2, 2, 2, 2, 2],
	'Ramp': [2, 2, 2, 1.5, 1, 1, 1, 1.5],
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

func _ready():
	#_remove_most_cells()
	_init_astar()
	
func _remove_most_cells():
	var keep = [Vector2(-1,-1), Vector2(0,0), Vector2(0, -2), Vector2(-1, -3)]
	for cell in get_used_cells():
		if keep.find(Vector2(cell.x, cell.z)) == -1:
			set_cell_item(cell.x, cell.y, cell.z, INVALID_CELL_ITEM)

var offset_x = 0
var offset_z = -2
func find_path(start, end):
	print("find_path ", start, end)
	var possible_starts = filter_tiles(start.x + offset_x, start.y + offset_z)
	var possible_ends = filter_tiles(end.x + offset_x, end.z + offset_z)
	if possible_starts.size() == 1 and possible_ends.size() == 1:
		var start_id = vector_to_id(possible_starts[0])
		var end_id = vector_to_id(possible_ends[0])
		var path = astar.get_point_path(start_id, end_id)
		print("found_path ", path)
		return path
	elif possible_starts.size() == 0 or possible_ends.size() == 0:
		print('Unable to find a possible start/end tile for pathfinding')
	elif possible_starts.size() > 1 or possible_ends.size() > 1:
		print_debug("Multiple possible start/end tiles found for pathfinding")
	return []

func vector_to_id(vector):
	return tiles.find(vector)
	
func filter_tiles(x, z):
	var output = []
	for tile in tiles:
		if(tile.x == x and tile.z == z):
			output.push_back(tile)
	return output

func _init_astar():
	var ground_cells = get_used_cells()
	var iterated_types = []
	var structure_tiles = []
	for cell in ground_cells:
		var itemId = get_cell_item(cell.x, cell.y, cell.z)
		var name = mesh_library.get_item_name(itemId)
		if decorations.find(name) != -1:
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
				astar.add_point(tiles.size(), cell)
				if debug:
					print('adding "', name, '" ', cell, ' as tile #', tiles.size())
				tiles.push_back(cell)
				counts.passable_tiles += 1
			else:
				counts.excluded_tiles += 1
		else:
			counts.excluded_tiles += 1
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
	
func _connect_points():
	for cell in tiles:
		var neighbours = _get_neighbors(cell)
		for neighbour in neighbours:
			_connect_cells(cell, neighbour)

func _connect_cells(a_cell, b_cell, upsert = false):
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
	for cell in cells:
		var itemId = get_cell_item(cell.x, cell.y, cell.z)
		var name = mesh_library.get_item_name(itemId)
		var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
		
		match name:
			'Smallbridge':
				# [NW, N, NE, E, SE, S, SW, W]
				var before_cardinals = [null, -1, null, null, null, null, null, null]
				var after_cardinals = [null, null, null, null, null, -1, null, null]
				var cardinalDelta = cardinalDeltas[orientationModifier[orientation] + 1]
				
				var before_cell = null
				for y in range(cell.y, cell.y - 3, -1):
					before_cell = Vector3(cell.x - cardinalDelta.x, y, cell.z - cardinalDelta.y)
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
					bridge_tile = Vector3(cell.x + cardinalDelta.x * mult, cell.y, cell.z + cardinalDelta.y * mult)
					_connect_cells(prev_tile, bridge_tile, true)
					
				# TODO: not working for 0 degree orientation
				var after_cell = null
				for y in range(cell.y, cell.y - 3, -1):
					after_cell = Vector3(bridge_tile.x + cardinalDelta.x, y, bridge_tile.z + cardinalDelta.y)
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
	var neighbours = []
	# deltas = Vector2(x_delta, z_delta)
	for deltas in cardinalDeltas:
		var idx = cardinalDeltas.find(deltas)
		var expected_height = cell.y + get_cardinal_height(cell, idx)
		if expected_height == null:
			continue
		
		for level_delta in range(0, expected_height):
			var neghbour = Vector3(cell.x + deltas.x, cell.y + level_delta, cell.z + deltas.y)
			if (get_cell_item(neghbour.x, neghbour.y, neghbour.z) == GridMap.INVALID_CELL_ITEM):
				continue
			var neighbour_height = get_cardinal_height(neghbour, idx + 4)
			if neighbour_height == null:
				continue
			var computed_height = neghbour.y + get_cardinal_height(neghbour, idx + 4)
			if computed_height == expected_height:
				var itemId = get_cell_item(neghbour.x, neghbour.y, neghbour.z)
				var neighbour_name = mesh_library.get_item_name(itemId)
				neighbours.push_back(neghbour)		
	return neighbours

func get_cardinal_height(cell, dir_idx):
	var itemId = get_cell_item(cell.x, cell.y, cell.z)
	var name = mesh_library.get_item_name(itemId)
	
	if decorations.find(name) != -1 or structures.find(name) != -1:
		return null
	var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
	if orientation == -1:
		return null
	if not orientationModifier.has(orientation):
		print_debug('Unexpected orientation (', orientation, ') for cell (', cell, '). Assuming no neighbours.')
		return null
	return cardinalHeights[name][(dir_idx + orientationModifier[orientation]) % cardinalDeltas.size()]
