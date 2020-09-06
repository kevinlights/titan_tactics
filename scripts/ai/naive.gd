extends Object
class_name NaiveAI

var world
var characters
var i_am = Game.CONTROL.AI

func _init(my_world):
	world = my_world
	characters = world.current[Game.CONTROL.AI]
#	for character in characters:
#		character.connect("idle", self, "play")
	
func play():
	if world.game_over:
		return
	var character = world.get_current()
	if character.character.control != Game.CONTROL.AI:
		print("AI (" + character.character.name + ") says not my turn, skipping")
		return
	print("AI taking turn")
	if character.character.has_ability(Game.ABILITY.HEAL):
		var weakest = get_weakest_ally(character)
		if weakest:
			print("AI (" + character.character.name + ") says heal " + weakest.character.name)
			character.heal(weakest)
			character.is_done = true
			world.advance_turn()
			return
	var enemy = get_nearest_enemy(character.position)
	if enemy:
		print("does it have heal? : " + str(character.character.has_ability(Game.ABILITY.HEAL)))
		if character.can_recruit() and character.character.has_ability(Game.ABILITY.HEAL):
			print("AI (" + character.character.name + ") says heal")
			character.heal(character)
			character.is_done = true
			world.advance_turn()
			return
		if enemies_are_stronger(character.position, character):
			print("AI (" + character.character.name + ") says guard")
			character.guard()
#			world.advance_turn()
			return
		var distance = character.tile.distance_to(enemy.tile)
		if distance <= character.character.atk_range and character.character.turn_limits.actions > 0 and not world.is_cover_between(character, enemy.position):
			print("AI (" + character.character.name + ") says attack")
			world.gui.battle(character, enemy)
			character.attack(enemy)
			character.is_done = true
			world.advance_turn()
			return
		if character.character.turn_limits.move_distance > 1 and distance > character.character.atk_range:
			var path = get_path_to(character.tile, enemy.tile, character.character.turn_limits.move_distance, character)
			if path and path.size() > 1:
				print("AI (" + character.character.name + ") says move")
				character.move(path)
				world.get_node("select").tile = path[path.size() - 1] / Vector2(Game.cell_size, Game.cell_size)
				if not character.is_connected("path_complete", self, "play"):
					character.connect("path_complete", self, "play")
				return
			else:
				print("AI (" + character.character.name + ") says wait (path too short)")
				character.is_done = true
				world.advance_turn()
				return
		else:
			print("AI (" + character.character.name + ") says wait (out of moves)")
			character.is_done = true
			world.advance_turn()
			return
		# if we reach this point, abandon turn
		print("AI (" + character.character.name + ") abandons turn, exhausted options")
		character.is_done = true
		world.advance_turn()
		return
	else:
		print("AI (" + character.character.name + ") says wait (nothing to do)")
		character.is_done = true
		world.advance_turn()


func get_path_to(start, end, max_length, character):
	var path = world.pathfinder.find_path(start, end)
	path = shorten_to_atk_range(path, character)
	var fixed_path = normalize_path(path, max_length)
	# prevent landing on a tile that has someone on it
	while fixed_path.size() > 1 and world.entity_at(fixed_path[fixed_path.size() - 1] / Vector2(Game.cell_size, Game.cell_size)):
		fixed_path.resize(fixed_path.size() - 1)
	return fixed_path

func normalize_path(path, max_length):
	if path.size() == 0:
		return path
	if path.size() > max_length:
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
	

func enemies_are_stronger(position, character):
	var enemies_in_range = 0
	var stronger_in_range = 0
	if character.can_recruit():
		var enemies = world.current[Game.CONTROL.PLAYER]
		for enemy in enemies:
			var distance = character.tile.distance_to(enemy.tile)
			if distance <= enemy.character.atk_range:
				enemies_in_range += 1
				if enemy.character.character_class == character.character.weakness:
					stronger_in_range += 1 
	return enemies_in_range == stronger_in_range and enemies_in_range > 0

func shorten_to_atk_range(path, character):
	for pos in range(path.size()):
		var distance = (path[-1] - path[pos]).length()
		if distance < character.character.atk_range:
			path.resize(pos)
			break
	return path
	
func get_weakest_ally(i_am):
	var weakest
	var lowest_hp = 999
	for ally in characters:
		if ally != i_am:
			var distance = i_am.tile.distance_to(ally.tile)
			if distance < i_am.character.atk_range:
				if ally.can_recruit():
					if ally.character.hp < lowest_hp:
						lowest_hp = ally.character.hp
						weakest = ally
	return weakest

