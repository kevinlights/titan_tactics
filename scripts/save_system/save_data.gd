extends Resource
class_name SaveData

export(int) var level = 0
export(Array) var team = []

func populate():
	level = Game.level
	team = Game.team

func load():
	Game.level = level
	Game.team = team
