extends Object
class_name SmortAI

var world
var characters
var i_am = TT.CONTROL.AI
var visual_range = 5

func _init(new_world):
	self.world = new_world
	characters = self.world.current[TT.CONTROL.AI]

func should_idle(character):
	var enemy = get_nearest_enemy(character.translation)
	var distance = character.translation.distance_to(enemy.translation)
	return distance > visual_range
		
	
func play():
	if world.game_over:
		return
	var character = world.get_current()
	if should_idle(character):
		print("[AI] (" + character.character.name + ") idle")
		character.is_done = true
		world.advance_turn()
		return
	print("[AI] (" + character.character.name + ") play")
	world.get_node("lookat/camera").track(character)
	if character.character.control != TT.CONTROL.AI:
		print("[AI] (" + character.character.name + ") not my turn, skipping")
		return
	yield(world.get_tree().create_timer(2.0), "timeout")
	if character.character.has_ability(TT.ABILITY.HEAL):
		var dying = get_dying_ally(character)
		if dying:
			print("[AI] (" + character.character.name + ") heal " + dying.character.name)
			character.heal(dying)
			character.is_done = true
			yield(world.get_tree().create_timer(2.0), "timeout")
			world.advance_turn()
			return
	var enemy = get_nearest_enemy_with_disadvantage(character)
	if not enemy or !can_attack(character, enemy):
		enemy = get_nearest_enemy(character.translation)
	if enemy:
		if character.can_recruit() and character.character.has_ability(TT.ABILITY.HEAL):
			print("[AI] (" + character.character.name + ") heal self")
			character.heal(character)
			character.is_done = true
			yield(world.get_tree().create_timer(2.0), "timeout")
			world.advance_turn()
			return
		if can_attack(character, enemy):
			print("[AI] (" + character.character.name + ") attack")
			world.gui.start("battle", enemy)
			character.attack(enemy)
			character.connect("attack_complete", self, "play", [], CONNECT_ONESHOT)
			return
		else:
			print("[AI] (" + character.character.name + ") can't attack")
		if character.character.turn_limits.move_distance > 1 and not can_attack(character, enemy):
			var path = get_path_to(character, enemy, character.character.turn_limits.move_distance)
			if path and path.size() > 1:
				print("[AI] (" + character.character.name + ") move")
				character.move(path)
				world.get_node("select").tile = path[path.size() - 1]
				character.connect("path_complete", self, "play", [], CONNECT_ONESHOT)
				return
			else:
				print("[AI] (" + character.character.name + ") no path")
				if not try_guarding(character):
					print("[AI] (" + character.character.name + ") wait (no path)")
				character.is_done = true
				yield(world.get_tree().create_timer(2.0), "timeout")
				world.advance_turn()
				return
		else:
			if not try_guarding(character):
				print("[AI] (" + character.character.name + ") wait (out of moves)")
			character.is_done = true
			yield(world.get_tree().create_timer(2.0), "timeout")
			world.advance_turn()
			return
		# if we reach this point, abandon turn
#		if not try_guarding(character):
#			print("[AI] (" + character.character.name + ") abandons turn, exhausted options")
#		character.is_done = true
#		yield(world.get_tree().create_timer(2.0), "timeout")
#		world.advance_turn()
#		return
	else:
		print("[AI] (" + character.character.name + ") can't find anyone to attack!")
		if not try_guarding(character):
			print("[AI] (" + character.character.name + ") wait (nothing to do)")
		character.is_done = true
		yield(world.get_tree().create_timer(2.0), "timeout")
		world.advance_turn()

func try_guarding(character):
	if character.character.turn_limits.actions < 1:
		return false
	print("[AI] (" + character.character.name + ") guard (last resort)")
	character.guard()
	return true

func distance_between(attacker, target):
	var attacker_cell = attacker.to_global(attacker.get_node("ranged_weapon").translation)
	var target_cell = target.translation + Vector3(0.5, 0.5, 0.5)
	# logic for disallowing diagonal attacks
	# return abs(target_cell.x - attacker_cell.x) + abs(target_cell.z - attacker_cell.z)
	# improved logic, matching character controller's can_attack_tile	
	var from_tile = Vector2(attacker_cell.x, attacker_cell.z)
	var to_tile = Vector2(target_cell.x, target_cell.z)
	var distance = from_tile.distance_to(to_tile)
	if attacker.character.atk_range == 1:
		return distance
	else:
		return floor(distance)
	
func can_attack(attacker, victim, ignore_action_limit = false):
	if attacker.character.turn_limits.actions < 1 and not ignore_action_limit:
		return false
	var distance = distance_between(attacker, victim)
	var cover = world.is_cover_between(attacker, victim.translation)
	if not cover:
#		print("no cover")
#		var int_distance = int(distance * 10)
#		distance = float(int_distance) / 10.0
#		distance = floor(distance)
		print("[AI] ", distance, " <= ", attacker.character.atk_range)
		if distance <= attacker.character.atk_range:
#			print("in range")
			return true
	return false

func can_attack_from(position, attacker, victim):
	var attack_origin = Vector3(0.5, 0.5, 0.5)
	attacker.get_node("ranged_weapon").translation = attacker.to_local(position) + attack_origin + Vector3(0, .5, 0)
	var i_can_attack = can_attack(attacker, victim, true)
	attacker.get_node("ranged_weapon").translation = attack_origin
	return i_can_attack

func get_path_to(character, target, max_length):
	var path = world.pathfinder.find_path(character.tile, target.tile, world.get_blocked_cells())
	path = shorten_to_atk_range(path, character, target)
	var fixed_path = normalize_path(path, max_length)
	# prevent landing on a tile that has someone on it
	while fixed_path.size() > 1 and world.entity_at(fixed_path[fixed_path.size() - 1]):
		fixed_path.resize(fixed_path.size() - 1)
	return fixed_path

func normalize_path(path, max_length):
	if path.size() == 0:
		return path
	if path.size() > max_length:
		path.resize(max_length)
	return world.to_world_path(path)

func get_nearest_enemy(translation):
	var enemies = world.current[TT.CONTROL.PLAYER]
	var shortest = 999
	var closest
	for enemy in enemies:
		var distance = translation.distance_to(enemy.translation)
		if distance < shortest:
			shortest = distance
			closest = enemy
	return closest

func get_nearest_enemy_with_disadvantage(character):
	var enemies = world.current[TT.CONTROL.PLAYER]
	var shortest = 999
	var closest
	for enemy in enemies:
		if enemy.character.weakness == character.character.character_class:
			var distance = character.translation.distance_to(enemy.translation)
			if distance < shortest:
				shortest = distance
				closest = enemy
	return closest
	
func shorten_to_atk_range(path, character, target):
	for pos in range(path.size()):
		var can_attack_from_here = can_attack_from(path[pos], character, target)
		if can_attack_from_here:
			if pos + 1 < path.size():
				path.resize(pos + 1)
			break
	return path

# only return weak allies with less than 10% of their HP so we don't waste heals on healthy individuals
func get_dying_ally(me):
	var weakest
	var lowest_hp = 999
	for ally in characters:
		if ally != me:
			var distance = me.tile.distance_to(ally.tile)
			if distance < me.character.atk_range:
				if ally.can_recruit():
					if ally.character.hp < lowest_hp and ally.character.max_hp / 10 < ally.character.hp:
						lowest_hp = ally.character.hp
						weakest = ally
	return weakest

