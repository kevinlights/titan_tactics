extends Node

var save_file_path = 'res://saves/save1.tres' # save/load from disk
#var save_file_path = 'user://savegame-0.0.2.save' # save/load from user space

var has_save_file = false 
func _ready():
	var save_file = File.new()
	if save_file.file_exists(save_file_path):
		has_save_file = true
	
func save_game():
	var data = SaveData.new()
	data.populate()
	ResourceSaver.save(save_file_path, data)
	
func load_game():
	if not has_save_file:
		return
	var data = load(save_file_path)
	data.load()
