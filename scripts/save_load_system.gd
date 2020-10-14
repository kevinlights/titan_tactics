extends Node

func _ready():
	pass # Replace with function body.

func has_save_file():
	var save_file = File.new()
	return save_file.file_exists("user://savegame.save")

func save_game():
	var save_dict = {
		"level": Game.level,
		"team": Game.team,
	}
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	save_file.store_line(to_json(save_dict))
	save_file.close()
	
func load_game():
	if not has_save_file():
		return
	var save_file = File.new()
	save_file.open("user://savegame.save", File.READ)
	var save_data = parse_json(save_file.get_line())
	Game.level = save_data.level
	Game.team = save_data.team
