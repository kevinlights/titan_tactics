extends Control

export(int) var progress = 0 setget _progress_changed

func _progress_changed(newVal):
	progress = newVal
	var level: Level = get_tree().get_root().get_node("World/level")
	level._overlay(newVal, 200)
	
