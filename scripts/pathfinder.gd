class_name PathFinder
extends Object

var width = 0
var height = 0
var collision_map
var walkable = []
var astar = AStar2D.new()

func _init(tile_map, walkable_tiles):
	collision_map = tile_map
	walkable = walkable_tiles
	var used_rect = tile_map.get_used_rect()
	width = used_rect.size.x
	height = used_rect.size.y
	# register points
	for y in range(height):
		for x in range(width):
			var point = Vector2(x, y)
			if valid_node(point):
				var point_id = vector_to_id(point)
				astar.add_point(point_id, point)
	# connect points
	for y in range(used_rect.size.y):
		for x in range(used_rect.size.x):
			var point = Vector2(x, y)
			if valid_node(point):
				var neighbors = get_neighbors(point)
				var id = vector_to_id(point)
				for neighbor in neighbors:
					var neighbor_id = vector_to_id(neighbor)
					if not astar.are_points_connected (id, neighbor_id):
						astar.connect_points(id, vector_to_id(neighbor))

func get_neighbors(path_node):
	var neighbors = []
	var directions = [
		Vector2(0, -1), Vector2(-1, -1), Vector2(-1, 0), Vector2(1, 1),
		Vector2(1, 0), Vector2(0, 1), Vector2(-1, 1), Vector2(1, -1)
	]
	for direction in directions:
		if valid_node(path_node + direction):
			neighbors.append(path_node + direction)
	return neighbors

func vector_to_id(vector_position):
	return vector_position.x + (vector_position.y * width)

func valid_node(node_position:Vector2):
	return (node_position.x >= 0 and
		node_position.x < width and
		node_position.y >= 0 and 
		node_position.y < height and
		collision_map.get_cellv(node_position) in walkable)

func find_path(start, end):
	return astar.get_point_path(vector_to_id(start), vector_to_id(end))
