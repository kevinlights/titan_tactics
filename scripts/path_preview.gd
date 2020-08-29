extends Node2D


export(Color) var good_color
export(Color) var bad_color

func preview_path(path, allowed = true):
	var world_path = PoolVector2Array()
	for point in path:
		world_path.append(point * Vector2(Game.cell_size, Game.cell_size))

	$path.default_color = good_color if allowed else bad_color
		
	$path.set_points(world_path)
	$path.show()

func hide_path():
	$path.hide()
	
