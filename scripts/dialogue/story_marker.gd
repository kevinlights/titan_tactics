tool
class_name StoryMarker
extends Sprite3D

export(String) var marker_name

func _enter_tree():
	axis = 1
	pixel_size = 0.08
	translation.y = 0.2
	texture = load("res://gfx/speak_map.png")
	add_to_group("story_markers") # so world can find it
	if not Engine.editor_hint:
		hide()
