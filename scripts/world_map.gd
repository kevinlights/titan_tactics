extends Control

var level_markers = [
	Vector2(70, 134),
	Vector2(54, 103),
	Vector2(82, 86),
	Vector2(65, 58),
	Vector2(42, 75),
	Vector2(116, 65),
	Vector2(180, 65),
	Vector2(214, 85),
	Vector2(246, 107),
	Vector2(267, 95)
]

func _ready():
	move_selector()

func move_selector():
	$text.text = "Level " + str(Game.level + 1) + ": " + TT.levels[Game.level].name
	$map_selector.position = level_markers[Game.level]

func _input(event):
	var lvl = Game.level
	if event.is_action("ui_down") && event.is_pressed():
		lvl -= 1
	if event.is_action("ui_up") && event.is_pressed():
		lvl += 1
	Game.level = clamp(lvl, 0, TT.levels.size() -1)
	move_selector()
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		yield(get_tree().create_timer(0.3), "timeout")
		get_tree().change_scene("res://scenes/world.tscn")