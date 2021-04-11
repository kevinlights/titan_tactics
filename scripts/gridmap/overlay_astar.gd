extends GridMap

onready var astar := AStar.new()
onready var tiles := []
onready var counts := {
	'connections': 0,
	'added_tiles': 0,
	'excluded_tiles': 0,
	'removed_tiles': 0,
}

var debug := false # change to true to increase logging
var debug_path := false # change to true to increase logging
var hide_non_walkable_tiles := true # change to true to visually debug
var no_diagonal_movement := true # change to false to allow diagonal movement

# Cardinals
# nw, n, ne
# w ,  , e
# sw, s, se
var cardinalHeights := { # y_deltas
	# tile_type: [NW, N, NE, E, SE, S, SW, W]
	'flat': [0, 0, 0, 0, 0, 0, 0, 0],
	'angled': [1, 1, 1, 0.5, 0, 0, 0, 0.5],
	'bridge': [1, 1, 1, sqrt(3)/2, 0, 0, 0, sqrt(3)/2],
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

func init_astar():
	var ground_cells = get_used_cells()
	var iterated_types = []
	var structure_tiles = []
	var multi_tiles = []
	
	var cells_added = 0
	var cells_excluded = 0
	for cell in ground_cells:
		var name = get_cell_name(cell)

		if !iterated_types.has(name):
			iterated_types.append(name)

		if not cardinalHeights.has(name):
			counts.excluded_tiles += 1
			if debug:
				print_debug("Missing cardinal heights for '", name, "' type. Excluding all occurances from walkable tiles.")
			continue
		if cardinalHeights.has(name):
			counts.added_tiles += 1
			astar.add_point(tiles.size(), cell)
			if debug:
				print('adding "', name, '" ', cell, ' as tile #', tiles.size())
			tiles.push_back(cell)
	
	_connect_points()
	
	var cells_removed = 0
	if hide_non_walkable_tiles:
		for cell in ground_cells:
			var cell_id = vector_to_id(cell)
			if cell_id == -1:
				counts.removed_tiles += 1
				set_cell_item(cell.x, cell.y, cell.z, INVALID_CELL_ITEM)
			else:
				var connections = astar.get_point_connections(cell_id)
				if connections.size() == 0:
					counts.removed_tiles += 1
					set_cell_item(cell.x, cell.y, cell.z, INVALID_CELL_ITEM)
	print(counts)
	print('astar pathfinding populated')

func _connect_points():
	for cell in tiles:
		if not cell:
			continue
		var neighbours = _get_neighbors(cell)
		for neighbour in neighbours:
			_connect_cells(cell, neighbour)

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
#				var neighbour_name = get_cell_name(neghbour)
				neighbours.push_back(neghbour)
	return neighbours

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

func get_cardinal_height(cell, dir_idx):
	var name = get_cell_name(cell).split('_')[0]
	
	if not cardinalHeights.has(name):
#		print_debug('Unexpected cell type. Assuming not walkable.')
		return null
	var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
	if orientation == -1:
		return null
	if not orientationModifier.has(orientation):
		print_debug('Unexpected orientation (', orientation, ') for cell (', cell, '). Assuming no neighbours.')
		return null
	return cardinalHeights[name][(dir_idx + orientationModifier[orientation]) % cardinalDeltas.size()]

func vector_to_id(vector):
	return tiles.find(vector)
func get_cell_name(cell):
	var itemId = get_cell_item(cell.x, cell.y, cell.z)
	if itemId < 0:
		return ""
	var name = mesh_library.get_item_name(itemId)
	return name

func generate_walking_path(path):
	var walking_path = []
	for i in range(path.size()):
		var cell = path[i]
		var name = get_cell_name(cell)
		var middle = cell
		if name.begins_with('angled'):
			middle.y += 0.5
		if name.begins_with('bridge'):
			middle.y += sqrt(3)/2
		if i > 0:
			var last_move = walking_path.back()
			var one_quarter = (middle + last_move) / 2
			if name.begins_with('flat'):
				one_quarter.y = middle.y
			if name.begins_with('bridge'):
				var diff = abs(middle.y - one_quarter.y)
				if diff > 0.433 and diff < 0.434:
					one_quarter.y += 0.228425126
			walking_path.append(one_quarter)
		walking_path.append(middle)
		if i < path.size() - 1:
			var next_cell = path[i+1]
			var edge = ((cell + next_cell) / 2)
			
			var expected_cardinal = Vector2(next_cell.x, next_cell.z) - Vector2(cell.x, cell.z)
			var expected_cardinal_idx = cardinalDeltas.find(expected_cardinal)
			var expected_edge_height = cell.y + get_cardinal_height(cell, expected_cardinal_idx)
			var actual_edge_height = next_cell.y + get_cardinal_height(next_cell, expected_cardinal_idx + 4)
			if expected_edge_height == actual_edge_height:
				edge.y = expected_edge_height
			var three_quarters = (middle + edge) / 2
			if name.begins_with('flat'):
				three_quarters.y = middle.y
			if name.begins_with('bridge'):
				var diff = abs(middle.y - three_quarters.y)
				if diff > 0.433 and diff < 0.434:
					three_quarters.y += 0.228425126
			walking_path.append(three_quarters)
			walking_path.append(edge)
	for i in range(walking_path.size()):
		walking_path[i].y -= 2
		walking_path[i].y /= 2
	return walking_path

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
		return path
	elif possible_starts.size() == 0 or possible_ends.size() == 0:
		print('Unable to find a possible start/end tile for pathfinding ', possible_starts, possible_ends)
	elif possible_starts.size() > 1 or possible_ends.size() > 1:
		print_debug("Multiple possible start/end tiles found for pathfinding")
		print(possible_starts, ' ', possible_ends)
	return []

func filter_tiles(x, z):
	var output = []
	for tile in tiles:
		if(tile and tile.x == x and tile.z == z):
			output.push_back(tile)
	return output

func world_path(path:PoolVector3Array):
	var w_path = PoolVector3Array()
	for point in path:
		w_path.append(point_to_world(point, false))
	print('w_path: ', w_path)
	return w_path

func point_to_world(point: Vector3, exclude_y: bool):
	var offset = get_parent().get_parent().translation + Vector3(-0.5, 0, -0.5)
	offset.y = 0
	var y = 0.0
	if !exclude_y:
		y = point.y - 1.25
		var name = get_cell_name(point)
	return map_to_world(point.x, y, point.z) + offset


#	if exclude_y:
#		offset.y = 0.0
#	else:
#		offset.y = point.y - 1.25
#	return map_to_world(point.x, 0, point.z) + offset
