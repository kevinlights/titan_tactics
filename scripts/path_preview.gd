extends Spatial


export(Color) var good_color
export(Color) var bad_color

func preview_path(path, allowed = true):
	var world_path = PoolVector2Array()
	for point_3d in path:
		var point = Vector2(point_3d.x, point_3d.z)
		world_path.append(point * Vector2(TT.cell_size, TT.cell_size))

	$path.default_color = good_color if allowed else bad_color
		
	$path.set_points(world_path)
	$path.show()

func hide_path():
	$path.hide()
	
