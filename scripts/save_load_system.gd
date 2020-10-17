extends Node

var save_file_path = 'user://savegame.000.save'
var has_save_file = false 
func _ready():
	var save_file = File.new()
	if save_file.file_exists(save_file_path):
		has_save_file = true
	
func save_game():
	var save_file = File.new()
	save_file.open(save_file_path, File.WRITE)
	save_file.store_line(to_json(save_dict()))
	save_file.close()
	
func load_game():
	if not has_save_file:
		return
	var save_file = File.new()
	save_file.open(save_file_path, File.READ)
	var save_data = parse_json(save_file.get_line())
	Game.level = save_data.level
	Game.team = []
	for character_dict in save_data.team:
		var character = dict2inst(character_dict)
		Game.team.push_back(character)
	
func save_dict():
	var save_dict = {
		"level": Game.level,
		"team": [],
	}
	for character in Game.team:
		save_dict.team.push_back(character_dict(character))
	return save_dict

func character_dict(character):
	var data = inst2dict(character)
	data.item_atk = inst2dict(character.item_atk)
	data.item_def = inst2dict(character.item_def)
	return data
