extends Control

var level_markers = [
	Vector2(70, 134),
	Vector2(54, 103),
	Vector2(82, 86),
	Vector2(53, 67),
	Vector2(118, 65),
	Vector2(191, 56),
	Vector2(235, 62),
	Vector2(181, 74),
	Vector2(138, 88),
	Vector2(104, 101)
]

func _ready():
	make_path_visible()
	move_selector()

func make_path_visible():
	var map_points = get_tree().get_nodes_in_group("map_points")
	$map_selector.visible = false
	var final_point
	var animated_path = []
	for i in range(0, map_points.size()):
		var map_point = map_points[i]
		if i == Game.unlocked_level:
			for child in map_point.get_children():
				child.visible = false
				animated_path.push_back(child)
			map_point.self_modulate.a = 0.0
			final_point = map_point
		map_point.visible = i <= Game.unlocked_level
	if final_point:
		for point in animated_path:
			yield(get_tree().create_timer(0.1), "timeout")
			point.visible = true
		yield(get_tree().create_timer(0.1), "timeout")
		final_point.self_modulate.a = 0.5
		yield(get_tree().create_timer(0.1), "timeout")
		final_point.self_modulate.a = 1
	$map_selector.visible = true

func move_selector():
	var level_count = Game.get_level_count()
	if(Game.level >= Game.get_level_count()):
		Game.level = Game.get_level_count() - 1
	$text.text = "Level " + str(Game.level + 1) + ": " + TT.levels[Game.level].name
	$map_selector.position = level_markers[Game.level]

enum DIR {
	UP, RIGHT, DOWN, LEFT
}
var lvl_dir_override = {
	4: {
		DIR.DOWN: -1,
		DIR.RIGHT: 1,
	},
	7: {
		DIR.LEFT: -1,
		DIR.DOWN: 1,
	}
}
func _input(event):
	var lvl = Game.level
	if event.is_pressed():
		if event.is_action("cheat_kill_everyone"):
			Game.unlocked_level += 1
			make_path_visible()
			return
		var dir
		if event.is_action("ui_up"):
			dir = DIR.UP
		elif event.is_action("ui_down"):
			dir = DIR.DOWN
		elif event.is_action("ui_left"):
			dir = DIR.LEFT
		elif event.is_action("ui_right"):
			dir = DIR.RIGHT
		if dir != null:
			if lvl_dir_override.has(Game.level + 1):
				var current_override = lvl_dir_override[Game.level + 1]
				if current_override.has(dir):
					lvl += current_override[dir]
			else:
				var current = level_markers[Game.level]
				if Game.level < 9:
					var next = level_markers[Game.level + 1]
					var matching_dirs = get_dirs(current, next)
					if matching_dirs.find(dir) > -1:
						lvl += 1
				if Game.level > 0:
					var prev = level_markers[Game.level - 1]
					var matching_dirs = get_dirs(current, prev)
					if matching_dirs.find(dir) > -1:
						lvl -= 1
			if lvl == Game.level:
				get_node('sfx/denied').play()
	Game.level = clamp(lvl, 0, TT.levels.size() -1)
	if Game.level > Game.unlocked_level:
		get_node('sfx/denied').play()
		Game.level = Game.unlocked_level
	move_selector()
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		yield(get_tree().create_timer(0.3), "timeout")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/world.tscn")

func get_dirs(start, end):
	var diff = (end - start)
	print(start, ' ', end, ' ', diff)
	var output = [];
	if diff.x > 0:
		output.push_back(DIR.RIGHT)
	if diff.x < 0:
		output.push_back(DIR.LEFT)
	if diff.y > 0:
		output.push_back(DIR.DOWN)
	if diff.y < 0:
		output.push_back(DIR.UP)
	print(output)
	return output
