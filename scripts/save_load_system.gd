extends Node

var save_file_path = 'user://savegame-0.0.5.save'
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
	Game.unlocked_level = save_data.unlocked_level
	Game.team = []

	for character_dict in save_data.team:
		# TODO: switch to json (or make conditional)
		var character = CharacterStatsOrig.new()
		character.from_save_data(character_dict)
		Game.team.push_back(character)
	
func save_dict():
	var save_dict = {
		"level": Game.level,
		"unlocked_level": Game.unlocked_level,
		"team": [],
	}
	for character in Game.team:
		save_dict.team.push_back(character.to_save_data())
	return save_dict
