tool
extends GridMap

var OverlayGridmap := preload("res://scripts/gridmap/overlay_gridmap.gd")

onready var overlay := get_node_or_null('overlay')
# vars used to populate overlay in the editor
onready var tile_count := len(get_used_cells())
onready var minCell := Vector3()
onready var maxCell := Vector3()

func _ready():
	if Engine.editor_hint:
		if overlay == null:
			overlay = OverlayGridmap.new()
			overlay.set_name('overlay')
			add_child(overlay)
			overlay.set_owner(owner)
			overlay._ready()

	if not Engine.editor_hint:
		if overlay:
			overlay.init_astar()
			overlay.blank_gridmap()
		_compute_bounds()

func is_tile_within(x, z):
	return (minCell.x <= x and maxCell.x >= x) and (minCell.z <= z and maxCell.z >= z)

# methods used for pathfinding
func find_path(start, end, blocked_cells = []):
	if !overlay:
		return []
	return overlay.find_path(start, end, blocked_cells)

func generate_walking_path(path):
	if !overlay:
		return []
	return overlay.generate_walking_path(path)
	

# methods used for range overlay
func set_tile_overlay(world_point, type):
	if not world_to_tile_map.has(world_point):
		var local_point = world_to_map(world_point)
		var possible_tiles = overlay.filter_tiles(local_point.x, local_point.z)
		if possible_tiles.size() == 1:
			var tile_id = overlay.tiles.find(possible_tiles[0])
			world_to_tile_map[world_point] = tile_id
	if world_to_tile_map.has(world_point):
		var tile_id = world_to_tile_map[world_point]
		var cell = overlay.astar.get_point_position(tile_id)
		if type == 'hint':
			type = null
		overlay.change_cell_to(cell, type)
		return true
	return false

onready var world_to_tile_map = {}
func get_tiles_within(_start, distance):
	var offset = get_parent().translation * -1
	var start = world_to_map(_start + offset)
	var possible_starts = overlay.filter_tiles(start.x, start.z)
	if possible_starts.size() == 1:
		var start_id = overlay.vector_to_id(possible_starts[0])
		var output_ids = []
		var start_ids = [start_id]
		for _i in range(0, distance):
			var next_ids = []
			for id in start_ids:
				for next in overlay.astar.get_point_connections(id):
					if next != start_id and output_ids.find(next) == -1:
						output_ids.push_back(next)
						next_ids.push_back(next)
				start_ids = next_ids
		var output_points = []
		for id in output_ids:
			var world_point = overlay.point_to_world(overlay.astar.get_point_position(id), false)
			if not world_to_tile_map.has(world_point):
				world_to_tile_map[world_point] = id
			output_points.push_back(world_point)
		return output_points
	else:
		return []

# methods used to populate overlay in the editor
func _physics_process(delta):
	if Engine.editor_hint:
		var new_tile_count = len(get_used_cells())
		if tile_count != new_tile_count:
			if OS.get_name() == 'OSX':
				return
			tile_count = new_tile_count
			#_debug_list_cells()
			_compute_bounds()
			print(overlay)
			if overlay != null:
				overlay.clear_gridmap()
			call_deferred("_populate_overlay")

func _debug_list_cells():
	var cells = get_used_cells()
	for cell in cells:
		var itemId = get_cell_item(cell.x, cell.y, cell.z)
		var worldCell = map_to_world(cell.x, cell.y, cell.z)
		var name = mesh_library.get_item_name(itemId)
		var navmesh = mesh_library.get_item_navmesh(itemId)
		var mesh = mesh_library.get_item_mesh(itemId)
		var collisions = mesh_library.get_item_shapes(itemId)
		print(
			'name: ', name, ' [', itemId, '], cell: ', cell, ', worldCell: ', worldCell,
			', collisions: ', collisions
		)

func _compute_bounds():
	var cells = get_used_cells()
	for cell in cells:
		var itemId = get_cell_item(cell.x, cell.y, cell.z)
		var aabb = mesh_library.get_item_mesh(itemId).get_aabb()
		var height = cell.y + floor(aabb.size.y)
		if cell.x < minCell.x:
			minCell.x = cell.x
		if cell.y < minCell.y:
			minCell.y = cell.y
		if cell.z < minCell.z:
			minCell.z = cell.z
		if cell.x > maxCell.x:
			maxCell.x = cell.x
		if height > maxCell.y:
			maxCell.y = height
		if cell.z > maxCell.z:
			maxCell.z = cell.z
			
func _populate_overlay():
	for z in range(maxCell.z, minCell.z - 1, -1):
		for x in range(minCell.x, maxCell.x + 1):
			_raycast_cell_detection(x, z, maxCell.y, 0)
	manually_populate_smallbridge()
	print(len(overlay.get_used_cells()))

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
func manually_populate_smallbridge():
	var deltaMappings = {
		0: cardinalDeltas[7],
		22: cardinalDeltas[1], # 90 deg,
		10: cardinalDeltas[3], # 180 deg,
		16: cardinalDeltas[5], # 270/-90 deg
	}
	for cell in get_used_cells():
		var itemId = get_cell_item(cell.x, cell.y, cell.z)
		var name = mesh_library.get_item_name(itemId)
		if name == 'Smallbridge':
			var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
			var cardinalDelta = deltaMappings[orientation]
			overlay.add_flat_cell(cell + Vector3(cardinalDelta.x, 0, cardinalDelta.y))
			if orientation == 22:
				overlay.add_bridge_cell(cell, 10)
				overlay.add_bridge_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 0)
			elif orientation == 16:
				overlay.add_bridge_cell(cell, 0)
				overlay.add_bridge_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 10)
			elif orientation == 10:
				overlay.add_bridge_cell(cell, 16)
				overlay.add_bridge_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 22)
			elif orientation == 0:
				overlay.add_bridge_cell(cell, 22)
				overlay.add_bridge_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 16)
			overlay.add_flat_cell(cell - 2 * Vector3(cardinalDelta.x, 0, cardinalDelta.y))

func _raycast_cell_detection(x, z, maxHeight, minHeight):
	#var last_filled_height = maxHeight * 2;
	for height in range(maxHeight, minHeight, -1):
		#if last_filled_height - height < 3:
		#	continue
		var worldCell = map_to_world(x, height, z)
		
		var nw = _raycast_relative_line_test(worldCell + Vector3(-0.5,0.01,0.5), Vector3(0.25, -0.25, -0.25))
		var n = _raycast_relative_line_test(worldCell + Vector3(-0.5,0.01,0), Vector3(0.25, -0.25, 0))
		var ne = _raycast_relative_line_test(worldCell + Vector3(-0.5,0.01,-0.5), Vector3(0.25, -0.25, 0.25))
		var e = _raycast_relative_line_test(worldCell + Vector3(0,0.01,-0.5), Vector3(0, -0.25, 0.25))
		var se = _raycast_relative_line_test(worldCell + Vector3(0.5,0.01,-0.5), Vector3(-0.25, -0.25, 0.25))
		var s = _raycast_relative_line_test(worldCell + Vector3(0.5,0.01,0), Vector3(-0.25, -0.25, 0))
		var sw = _raycast_relative_line_test(worldCell + Vector3(0.5,0.01,0.5), Vector3(-0.25, -0.25, -0.25))
		var w = _raycast_relative_line_test(worldCell + Vector3(0,0.01,0.5), Vector3(0, -0.25, -0.25))
		
		if (nw && n && ne) && !(e || se || s || sw || w):
			if _raycast_is_above_clear(worldCell):
				overlay.add_angled_cell(Vector3(x, height-1 , z), 16)
				#last_filled_height = height
				return true
		if (nw && w && sw) && !(n || ne || e || se || s):
			if _raycast_is_above_clear(worldCell):
				overlay.add_angled_cell(Vector3(x, height-1 , z), 10)
				#last_filled_height = height
				return true
		if (sw && s && se) && !(w || nw || n || ne || e):
			if _raycast_is_above_clear(worldCell):
				overlay.add_angled_cell(Vector3(x, height-1 , z), 22)
				#last_filled_height = height
				return true
		if (ne && e && se) && !(s || sw || w || nw || n):
			if _raycast_is_above_clear(worldCell):
				overlay.add_angled_cell(Vector3(x, height-1 , z), 0)
				#last_filled_height = height
				return true
		if (ne && e && se && s && sw && w && nw && n):
			if _raycast_is_above_clear(worldCell) and _raycast_is_above_clear(worldCell + Vector3(0, 0.5, 0)):
				overlay.add_flat_cell(Vector3(x, height, z))
				#last_filled_height = height
				return true

func _raycast_is_above_clear(worldCell, debug = false):
	#print('_raycast_is_above_clear ', worldCell)
	var tl = worldCell + Vector3(-0.5, 0.01, 0.5)
	var tr = worldCell + Vector3(-0.5, 0.01, -0.5)
	var bl = worldCell + Vector3(0.5, 0.01, 0.5)
	var br = worldCell + Vector3(0.5, 0.01, -0.5)
	var br_tl = _raycast_line_test(br, tl + Vector3(0, 0.49, 0), debug)
	var tr_bl = _raycast_line_test(tr, bl + Vector3(0, 0.49, 0), debug)
	#return !(br_tl || tr_bl)
	var cen_br = _raycast_line_test(worldCell, br + Vector3(0, 0.49, 0), debug)
	var cen_bl = _raycast_line_test(worldCell, bl + Vector3(0, 0.49, 0), debug)
	var cen_tr = _raycast_line_test(worldCell, tr + Vector3(0, 0.49, 0), debug)
	var cen_tl = _raycast_line_test(worldCell, tl + Vector3(0, 0.49, 0), debug)
	return !(cen_br || cen_bl || cen_tr || cen_tl)

func _raycast_line_test(from, to, debug = false):
	var world_from = to_global(from)
	var world_to = to_global(to)
	var intersects = get_world().direct_space_state.intersect_ray(world_from, world_to, [], 1)
	if debug:
		print(world_from, world_to, intersects)
	return len(intersects) > 0
	
func _raycast_relative_line_test(from, to, debug = false):
	return _raycast_line_test(from, from + to, debug)
