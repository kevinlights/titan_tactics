tool
extends "res://scripts/gridmap/overlay_astar.gd"

var overlay_meshlib := preload("res://gfx/range-overlay/overlay.meshlib")
onready var itemMapping := {
	'flat': -1,
	'flat_move': -1,
	'flat_attack': -1,
	'flat_placeholder': -1,
	'angled': -1,
	'angled_move': -1,
	'angled_attack': -1,
	'angled_placeholder': -1,
	'bridge': -1,
	'bridge_move': -1,
	'bridge_attack': -1,
	'bridge_placeholder': -1,
}

func _ready():
	set_mesh_library(overlay_meshlib)
	_copy_attrs_from_parent()
	_detect_meshlib_items()

func clear_gridmap():
	for cell in get_used_cells():
		set_cell_item(cell.x, cell.y, cell.z, INVALID_CELL_ITEM)
		
func blank_gridmap():
	for cell in get_used_cells():
		change_cell_to(cell, 'placeholder')

func change_cell_to(cell, type = null):
	var name = get_cell_name(cell)
	var cell_type = name.replace('_move', '').replace('_attack', '').replace('_placeholder', '')
	var new_name = cell_type
	if type:
		new_name += '_' + type
	var orientation = get_cell_item_orientation(cell.x, cell.y, cell.z)
	if itemMapping.has(new_name):
		set_cell_item(cell.x, cell.y, cell.z, itemMapping[new_name], orientation)
	else:
		print('error ', cell, type)

func add_flat_cell(cell):
	#print('add_flat_cell ', cell)
	set_cell_item(cell.x, cell.y, cell.z, itemMapping.flat)

func add_angled_cell(cell, orientation = 0):
	#print('add_angled_cell ', cell)
	set_cell_item(cell.x, cell.y, cell.z, itemMapping.angled, orientation)

func add_bridge_cell(cell, orientation = 0):
	#print('add_bridge_cell ', cell)
	set_cell_item(cell.x, cell.y, cell.z, itemMapping.bridge, orientation)
	
	
func _copy_attrs_from_parent():
	cell_center_x = get_parent().cell_center_x
	cell_center_y = get_parent().cell_center_y
	cell_center_z = get_parent().cell_center_z
	cell_octant_size = get_parent().cell_octant_size
	cell_scale = get_parent().cell_scale
	cell_size = get_parent().cell_size
	scale = get_parent().scale

func _detect_meshlib_items():
	for item_id in mesh_library.get_item_list():
		var name = mesh_library.get_item_name(item_id)
		if(itemMapping.has(name)):
			itemMapping[name] = item_id
	for key in itemMapping.keys():
		if itemMapping[key] == -1:
			print_debug("Overlay meshlib is missing ", key)
