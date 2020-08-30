extends Object
class_name NaiveAI

var world
var characters
var i_am = Game.CONTROL.AI

func _init(my_world):
	world = my_world
	characters = world.current[Game.CONTROL.AI]
	for character in characters:
		character.connect("idle", self, "play")
	
func play():
	if world.game_over:
		return
	var character = world.get_current()
	if character.character.control != Game.CONTROL.AI:
		print("Not my turn, skipping")
		return
	print("AI taking turn")
	var enemy = get_nearest_enemy(character.position)
	if enemy:
		var distance = character.tile.distance_to(enemy.tile)
		if distance < character.character.atk_range and character.character.turn_limits.actions > 0 and not world.is_cover_between(character.tile, enemy.tile):
			print("AI (" + character.character.name + ") says attack")
			character.attack(enemy)
			return
		if character.character.turn_limits.move_distance > 1 and distance > character.character.atk_range:
			var path = get_path_to(character.tile, enemy.tile, character.character.turn_limits.move_distance)
			if path and path.size() > 1:
				print("AI (" + character.character.name + ") says move")
				character.move(path)
				world.get_node("select").tile = path[path.size() - 1] / Vector2(Game.cell_size, Game.cell_size)
			else:
				print("AI (" + character.character.name + ") says wait (path too short)")
				world.advance_turn()
		else:
			print("AI (" + character.character.name + ") says wait (out of moves)")
			world.advance_turn()			
	else:
		print("AI (" + character.character.name + ") says wait (nothing to do)")
		world.advance_turn()


func get_path_to(start, end, max_length):
	var path = world.pathfinder.find_path(start, end)
	var fixed_path = normalize_path(path, max_length)
	# prevent landing on a tile that has someone on it
	while fixed_path.size() > 1 and world.entity_at(fixed_path[fixed_path.size() - 1] / Vector2(Game.cell_size, Game.cell_size)):
		fixed_path.resize(fixed_path.size() - 1)
	return fixed_path

func normalize_path(path, max_length):
	if path.size() == 0:
		return path
	path.resize(max_length)
	return world.to_world_path(path)

func get_nearest_enemy(position):
	var enemies = world.current[Game.CONTROL.PLAYER]
	var shortest = 999
	var closest
	for enemy in enemies:
		var distance = position.distance_to(enemy.position)
		if distance < shortest:
			shortest = distance
			closest = enemy
	return closest
		
