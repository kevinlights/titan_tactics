extends GridMap

const OverlayGridmap := preload("res://scripts/gridmap/overlay_gridmap.gd")

onready var executed := false
onready var overlay := OverlayGridmap.new()

onready var minCell := Vector3()
onready var maxCell := Vector3()
func _ready():
	add_child(overlay)
	#_debug_list_cells()
	_compute_bounds()
	print('min: ', minCell, ' max: ', maxCell)
		
func _physics_process(delta):
	if executed == false:
		call_deferred("_populate_overlay")
		executed = true

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
			_raycast_cell_detection(x, z, maxCell.y, minCell.y)
	
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
	var deltaMappings = {
		'Smallbridge': {
			0: cardinalDeltas[7],
			22: cardinalDeltas[1], # 90 deg,
			10: cardinalDeltas[3], # 180 deg,
			16: cardinalDeltas[5], # 270/-90 deg
		}
	}
	var cells = get_used_cells()
	for cell in cells:
		var itemId = get_cell_item(cell.x, cell.y, cell.z)
		var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
		var name = mesh_library.get_item_name(itemId)
		
		if name == 'Smallbridge':
			var cardinalDelta = deltaMappings[name][orientation]
			print('smallbridge: ', cell)
			overlay.add_flat_cell(cell + Vector3(cardinalDelta.x, 0, cardinalDelta.y))
			if orientation == 22:
				overlay.add_angled_cell(cell, 10)
				overlay.add_angled_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 0)
			elif orientation == 16:
				overlay.add_angled_cell(cell, 0)
				overlay.add_angled_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 10)
			elif orientation == 10:
				overlay.add_angled_cell(cell, 16)
				overlay.add_angled_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 22)
			elif orientation == 0:
				overlay.add_angled_cell(cell, 22)
				overlay.add_angled_cell(cell - Vector3(cardinalDelta.x, 0, cardinalDelta.y), 16)
			overlay.add_flat_cell(cell - 2 * Vector3(cardinalDelta.x, 0, cardinalDelta.y))
		
	overlay.init_astar()

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
			overlay.add_angled_cell(Vector3(x, height-1 , z), 16)
			#last_filled_height = height
			return true
		if (nw && w && sw) && !(n || ne || e || se || s):
			overlay.add_angled_cell(Vector3(x, height-1 , z), 10)
			#last_filled_height = height
			return true
		if (sw && s && se) && !(w || nw || n || ne || e):
			overlay.add_angled_cell(Vector3(x, height-1 , z), 22)
			#last_filled_height = height
			return true
		if (ne && e && se) && !(s || sw || w || nw || n):
			overlay.add_angled_cell(Vector3(x, height-1 , z), 0)
			#last_filled_height = height
			return true
		#if x == 2 and z == 0:
		#	print('cardinals ', height, ' ', nw, n, ne, e, se, s, sw, w)
		#if x == 2 and z == -2:
			#print('cardinals ', height, ' ', nw, n, ne, e, se, s, sw, w)
			#print('check ', _raycast_is_above_clear(worldCell, true))
		if (ne && e && se && s && sw && w && nw && n):
			if _raycast_is_above_clear(worldCell):
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
	return !(br_tl || tr_bl)
	#var cen_br = _raycast_test(worldCell, br + Vector3(0, 0.49, 0), debug)
	#var cen_bl = _raycast_test(worldCell, bl + Vector3(0, 0.49, 0), debug)
	#var cen_tr = _raycast_test(worldCell, tr + Vector3(0, 0.49, 0), debug)
	#var cen_tl = _raycast_test(worldCell, tl + Vector3(0, 0.49, 0), debug)
	#return !(cen_br || cen_bl || cen_tr || cen_tl)

func _raycast_line_test(from, to, debug = false):
	var intersects = get_world().direct_space_state.intersect_ray(from, to, [], 1)
	if debug:
		print(from, to, intersects)
	return len(intersects) > 0
	
func _raycast_relative_line_test(from, to, debug = false):
	return _raycast_line_test(from, from + to, debug)
	

func _raycast_test_orig():
	var ray = get_parent().get_node("RayCast")
	ray.force_raycast_update()
	var ray2 = get_parent().get_node("RayCast2")
	ray2.force_raycast_update()
	var ray3 = get_parent().get_node("RayCast3")
	ray3.force_raycast_update()
	print(ray.is_colliding(), ' ', ray2.is_colliding(), ' ', ray3.is_colliding())
	
func _raycast_test_new():
	var ray = get_parent().get_node("RayCast")
	var ray2 = get_parent().get_node("RayCast2")
	var ray3 = get_parent().get_node("RayCast3")
	print(_raycast_relative_line_test(ray.translation, ray.cast_to, true))
	print(_raycast_relative_line_test(ray2.translation, ray2.cast_to, true))
	print(_raycast_relative_line_test(ray3.translation, ray3.cast_to, true))
	
func find_path(start, end, blocked_cells = []):
	# TODO: compute path
	return []
