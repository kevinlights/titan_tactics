extends Node2D

signal win
signal auto_deployed
signal all_enemies_eliminated

enum TILEID {
	NOT_PASSABLE = 0,
	COVER,
	PLAYER_SPAWN,
	ENEMY_SPAWN_FIGHTER,
	ENEMY_SPAWN_MAGE,
	ENEMY_SPAWN_ARCHER
	ENEMY_SPAWN,
	PASSABLE,
	CHEST
}

onready var gui = get_tree().get_root().get_node("World/gui")

var tile_meta
var world_map
var game_over = false
var current_turn = Game.CONTROL.PLAYER
var player_spawns = []
var pathfinder
var ai
var current_character = 0
var turns = 0
var map_size = { "width": 10, "height": 10 }

var num_done = 0

var current = {
	Game.CONTROL.AI: [],
	Game.CONTROL.PLAYER: []
}

func load_level(level_name):
	print("Loading level " + level_name)
	var level = load("res://scenes/levels/" + level_name + ".tscn").instance()
	add_child_below_node($map_anchor, level)
	tile_meta = level.get_node("navigation/tile_meta")
	world_map = level.get_node("map")
	pathfinder = PathFinder.new(tile_meta, [ 2, 3, 4, 5, 7 ])
	var used_rect = tile_meta.get_used_rect()
	map_size.width = used_rect.size.x
	map_size.height = used_rect.size.y
	$select/camera.limit_bottom = map_size.height * Game.cell_size
	$select/camera.limit_right = map_size.width * Game.cell_size
	tile_meta.hide() # meta data should not be visible to the player	
	$select.disable()

func get_current():
	current_character = clamp(current_character, 0, abs(current[current_turn].size()-1))
	return current[current_turn][current_character]

func entity_at(position_vector):
	var characters = get_tree().get_nodes_in_group ("characters")
	for character in characters:
		if character.tile.x == position_vector.x and character.tile.y == position_vector.y and not character.is_dead:
			return character
	return null

func as_world_position(tile):
	return Vector2(tile.x * Game.cell_size, tile.y * Game.cell_size)

func make_tile(tile_id):
	return {
		"cover": tile_id == TILEID.COVER,
		"passable": tile_id != TILEID.NOT_PASSABLE and tile_id != TILEID.COVER
	}

func is_cover_between(character, end):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	print(space_state)
	var mid_point = Vector2(8, 8)
	var intersects = space_state.intersect_ray(character.position + mid_point, end + mid_point)
	print(intersects)
#	character.get_node("detect_cover").cast_to = (end) - character.position
#	var found_cover = character.get_node("detect_cover").is_colliding()
#	print("Found cover: ", found_cover)
	return !intersects.empty()

func spawn_cover(tile):
	var cover = load("res://scenes/cover_tile.tscn").instance()
	cover.position = tile * Vector2(Game.cell_size, Game.cell_size)
	world_map.add_child(cover)
	print("Spawned cover")
	return cover
	
func spawn_chest(x, y, item_spawner):
	var chest = load("res://scenes/chest.tscn").instance()
#	character.init(type, control)
	chest.teleport(x, y)
#	chest.level = Game.level + 1
	chest.item_spawner = item_spawner
	chest.add_to_group("characters")
	world_map.add_child(chest)
	print("Spawned chest")
	return chest

func spawn_character(x, y, type = Game.TYPE.MAGE, control = Game.CONTROL.PLAYER):
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	character.init(type, control)
	character.teleport(x, y)
	character.add_to_group("characters")
	world_map.add_child(character)
	return character

func advance_turn(explicit = 1, direction = 1):
	num_done = 0
	for character_check in current[current_turn]:
		if character_check.is_done:
			num_done += 1
	if num_done == current[current_turn].size():
		print("End turn")
		end_turn()
		return
	next_character(direction)
	while current[current_turn][current_character].is_done:
		next_character(direction)
		
	print("Advance turn")
	$select.set_origin(get_current())
	if explicit == 1:
		$select.disable()
		yield(get_tree().create_timer(1.0), "timeout")
	$path_preview/path.clear_points()
	if current_turn  == Game.CONTROL.AI:
		ai.play()
	elif explicit == 1:
		$select.enable()
	current_character = clamp(current_character, 0, current[current_turn].size() -1)

func next_character(direction):
	current_character += direction
	if current_character >= current[current_turn].size():
		current_character = 0
	if current_character < 0:
		current_character = current[current_turn].size() - 1

func change_character():
	$gui.swap()

func end_turn():
	#yield(get_tree().create_timer(2.0), "timeout")
#	current[current_turn][current_character]
	for character in current[Game.CONTROL.PLAYER]:
		character.is_done = false
		character.get_node("done").hide()
		
	current_turn = Game.CONTROL.AI if current_turn == Game.CONTROL.PLAYER else Game.CONTROL.PLAYER
	for character in current[current_turn]:
		character.end_turn()
	current_character = 0
#	$select.set_origin(get_current())
	gui.turn(current_turn)
#	gui.battle_hide(get_current())
	$select.disable()

func to_world_path(path):
	var world_path = PoolVector2Array()
	for point in path:
		world_path.append(point * Vector2(Game.cell_size, Game.cell_size))
	return world_path

func action():
	print ("world action")
	var context = get_current_context($select.tile)
	var current_path = pathfinder.find_path(get_current().tile, $select.tile)
	var target = entity_at($select.tile)
	#gui.battle()
	match(context):
		Game.CONTEXT.ATTACK:
			if get_current().character.turn_limits.actions > 0:
				if get_current().can_attack(target):
					if target.can_recruit() and is_adjacent(get_current(), target):
						gui.attack()
					else:
						_on_attack()
		Game.CONTEXT.USE:
			if is_adjacent(target, get_current()):
				if target.is_loot:
					var loot = target.open(get_current().character.character_class)
					if loot:
						yield(get_tree().create_timer(1.0), "timeout")
						print("item " + str(loot.name))
						if target.item_spawner.equipment_slot == 0:
							gui.loot(get_current().character.item_atk, loot, 0)
						if target.item_spawner.equipment_slot == 1:
							gui.loot(get_current().character.item_def, loot, 1)
				else:
					if target.available == "level_complete":
						if all_enemies_eliminated():
							target.use()
					else:
						target.use()
		Game.CONTEXT.MOVE:
			get_current().move(to_world_path(current_path))
			$path_preview.hide_path()
		Game.CONTEXT.NOT_ALLOWED:
			$gui/sfx/denied.play()
		Game.CONTEXT.GUARD:
#			if $gui/battle/box_enemy.visible:
#				return
			print("guard action")
			if get_current().character.turn_limits.actions == 0:
				get_current().is_done = true
				_on_end()
			else:
				gui.guard()
		Game.CONTEXT.HEAL:
#			if $gui/battle/box_enemy.visible:
#				return
			if get_current().character.turn_limits.actions == 0:
				_on_end()
			else:
				gui.guard(true)

func is_adjacent(one, two):
	return abs(one.tile.x - two.tile.x) <= 1 and abs(one.tile.y - two.tile.y) <= 1

func _ready():
	print(Game.team)
	randomize()
	
	load_level(Game.get_level())
	current[Game.CONTROL.PLAYER] = []
	current[Game.CONTROL.AI] = []
	player_spawns = []
	for x in range(map_size.width):
		for y in range(map_size.height):
			var tile_id = tile_meta.get_cell(x, y)
			if tile_id == TILEID.PLAYER_SPAWN:
				player_spawns.append(Vector2(x, y))
			if tile_id == TILEID.COVER:
				spawn_cover(Vector2(x, y))
	gui.get_node("action_menu").connect("attack", self, "_on_attack")
	gui.get_node("action_menu").connect("recruit", self, "_on_recruit")
	gui.get_node("action_menu").connect("guard", self, "_on_guard")
	gui.get_node("action_menu").connect("end", self, "_on_end")
	gui.get_node("action_menu").connect("heal", self, "_on_heal")
	gui.get_node("playerturn").connect("done", self, "_initiate_turn")
	gui.get_node("enemyturn").connect("done", self, "_initiate_turn")
	gui.get_node("intro").connect("closed", self, "select_team")
	gui.get_node("weaponswap").connect("swap", self, "_accept_loot")
	gui.get_node("weaponswap").connect("dont_swap", self, "_destroy_loot")
	gui.get_node("characterselect").connect("character_selected", self, "_on_select_team_member")
	gui.get_node("characterselect").connect("library_exhausted", self, "_on_team_select_done")
	gui.get_node("teamconfirm").connect("start_level", self, "_on_start_level")
	gui.get_node("teamconfirm").connect("check_map", self, "_on_check_map")
	gui.get_node("teamconfirm").connect("edit_team", self, "_on_edit_team")
	gui.get_node("lvlup").connect("close", self, "check_end_game")
	gui.get_node("win").connect("next", self, "_on_next_level")
	gui.get_node("win").connect("retry", self, "_on_replay")
	gui.get_node("lose").connect("retry", self, "_on_replay")
	$select.connect("moved", self, "_on_selector_moved")

	select_team()
	$music.get_node(Game.get_theme()).play()
	call_deferred("spawn_ai_team")
	call_deferred("spawn_chests")

func spawn_chests():
	var chest_spawns = get_tree().get_nodes_in_group("chest_spawns")
	for chest_spawn in chest_spawns:
		var chest = spawn_chest(
			floor(chest_spawn.position.x / Game.cell_size), 
			floor(chest_spawn.position.y / Game.cell_size),
			chest_spawn.item_spawner)
		chest_spawn.hide()
	
func spawn_ai_team():
	var ai_spawns = get_tree().get_nodes_in_group("ai_spawns")
	for ai_spawn in ai_spawns:
		var character:Node = load("res://scenes/character_controller.tscn").instance()
		character.from_spawner(ai_spawn)
		character.teleport(floor(ai_spawn.position.x / Game.cell_size), floor(ai_spawn.position.y / Game.cell_size))
		character.character.control = Game.CONTROL.AI
		character.add_to_group("characters")
		current[Game.CONTROL.AI].append(character) # spawn_character(floor(ai_spawn.position.x / Game.cell_size), floor(ai_spawn.position.y / Game.cell_size), ai_spawn.stats.character_class, Game.CONTROL.AI))
		current[Game.CONTROL.AI].back().connect("death", self, "_on_death")
		current[Game.CONTROL.AI].back().connect("done", self, "advance_turn")
		current[Game.CONTROL.AI].back().connect("dialogue", self, "_on_dialogue")
		world_map.add_child(character)
		ai_spawn.hide()
#	print(ai_spawns)
	ai = NaiveAI.new(self)
	
func select_team():
	for member in Game.team:
		member.hp = member.max_hp
		member.reset_turn() # reset actions and moves
	$select.tile = player_spawns[0]
	if Game.team.size() > 1:
		gui.team_select(Game.team)
	else:
		auto_deploy_only_character()


func _on_dialogue_complete(content):
	gui.back()
	print("character triggered dialogue complete")
	$select.enable()

func _on_dialogue(content):
	$select.disable()
	content.connect("completed", self, "_on_dialogue_complete")
	gui.dialogue(content)

func _on_team_select_done():
	gui.back()
	gui.team_confirm()

func _on_check_map():
	gui.back()
	#gui.get_node("sfx/select").play()
	$select.mode = $select.MODE.CHECK_MAP
	$select.call_deferred("enable")

func _on_edit_team():
	# rediscover player spawns
	player_spawns = []
	for x in range(map_size.width):
		for y in range(map_size.height):
			var tile_id = tile_meta.get_cell(x, y)
			if tile_id == TILEID.PLAYER_SPAWN:
				player_spawns.append(Vector2(x, y))
	# clear previously selected team
	for character in current[Game.CONTROL.PLAYER]:
		world_map.remove_child(character)
	current[Game.CONTROL.PLAYER].resize(0)
	# and start over
	gui.back()
	#gui.get_node("sfx/select").play()
	call_deferred("select_team")

func _on_start_level():
	gui.modal = false
	gui.back()
	#gui.get_node("sfx/select").play()
	$select.mode = $select.MODE.PLAY
	$select.set_origin(get_current())
	$select.call_deferred("enable")


func _on_win(ignore_dialogue = false):
	if not (gui.get_node("dialogue").visible or gui.get_node("lvlup").visible) or ignore_dialogue:
		print("win, dialogue: ", gui.get_node("dialogue").visible)
		gui.get_node("dialogue").hide()
		if Game.level + 1 < Game.get_level_count():
			gui.win()
		else:
			get_tree().change_scene("res://scenes/landing.tscn")
		$music/win.play()
		emit_signal("win")
		print("End game: WIN")

func all_enemies_eliminated():
	return current[Game.CONTROL.AI].size() == 0

func check_end_game(ignore_dialogue = false):
	if all_enemies_eliminated():
		emit_signal("all_enemies_eliminated")
	var triggers = get_tree().get_nodes_in_group ("dialogue_triggers")
	for trigger in triggers:
		print("Available ", trigger.available)
		print("Consumed ", trigger.consumed)
		if trigger.available == "level_complete" and !trigger.consumed:
			return false
	for control in [ Game.CONTROL.AI, Game.CONTROL.PLAYER ]:
		if current[control].size() == 0:
			game_over = true
			$select.disable()
			gui.call_deferred("battle_hide")
			if control == Game.CONTROL.AI:
				call_deferred("_on_win", ignore_dialogue)
			else:
				gui.lose()
				print("End game: LOSE")
				$music/lose.play()
			$music.get_node(Game.get_theme()).stop()
			return true
	return false

func _on_death(character):
	character.hide()
	var control = character.character.control
	current[control].erase(character)
	if not check_end_game():
		advance_turn()

func _on_replay():
	get_tree().reload_current_scene()

func _on_next_level():
	if Game.level + 1 < Game.get_level_count():
		Game.level += 1
		get_tree().reload_current_scene()
	else:
		# All levels completed?
		gui.back()
		gui.credits()
		$music.get_node(Game.get_theme()).stop()
		$music/win.play()

func auto_deploy_only_character():
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	var spawn = player_spawns.pop_front()
	character.from_library(Game.team[0])
	character.teleport(spawn.x, spawn.y)
	character.add_to_group("characters")
	world_map.add_child(character)
	current[Game.CONTROL.PLAYER].append(character)
	character.connect("done", self, "advance_turn")
	character.connect("death", self, "_on_death")
	character.character.control = Game.CONTROL.PLAYER
	character.character.connect("level_up", self, "_on_level_up")
	_on_start_level()
	emit_signal("auto_deployed")

func _on_select_team_member(team_member):
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	var spawn = player_spawns.pop_front()
	character.from_library(team_member)
	character.teleport(spawn.x, spawn.y)
	character.add_to_group("characters")
	world_map.add_child(character)
	current[Game.CONTROL.PLAYER].append(character)
	character.connect("done", self, "advance_turn")
	character.connect("death", self, "_on_death")
	character.character.control = Game.CONTROL.PLAYER
	character.character.connect("level_up", self, "_on_level_up")
	if player_spawns.size() > 0:
		$select.tile = player_spawns[0]
	else:
		_on_team_select_done()

func _on_level_up(diff, character):
	gui.call_deferred("level_up", diff, character)
#	gui.level_up(diff, character)

func _initiate_turn():
	# in case a signal triggers this after the level is won/lost
	if current[Game.CONTROL.AI].size() == 0 or current[Game.CONTROL.PLAYER].size() == 0:
		print("Don't initiate turn; the game is already over.")
		return
	if $select.disabled:
		print("initiate turn")
		gui.back()
		$select.enable()
		$select.set_origin(get_current())
		$select.set_context(get_current_context($select.tile))
	else:
		print("Don't initiate turn: selector is enabled")
	if current_turn == Game.CONTROL.AI:
		print("Control turned over to AI")
		ai.play()
	
func _on_attack():
	print("attack option selected in menu")
	if get_current().character.turn_limits.actions != 0:
		var target = entity_at($select.tile)
		if get_current().character.character_class != Game.TYPE.FIGHTER and is_cover_between(get_current(), target.position):
			gui.error("BLOCKED LINE OF SIGHT")
			gui.call_deferred("back")
			return
		var damage = get_current().attack(target)
		gui.call_deferred("close_attack")
		yield(get_tree().create_timer(2.0), "timeout")
		gui.call_deferred("battle_hide")
		
	else:
		gui.error("NO MORE ACTIONS")
		gui.call_deferred("back")

func _on_recruit_completed(id):
	gui.back()
	var target = entity_at($select.tile)
	get_current().character.turn_limits.actions -= 1
	if id == "accepted":
		target.recruit(get_current())
		target.character.control = Game.CONTROL.PLAYER
		Game.team.append(target.character)
		current[Game.CONTROL.AI].erase(target)
	else:
		target.recruit_failed(get_current())
		gui.error("FAILED TO RECRUIT")
	$select.go_home()
	$select.call_deferred("enable")

func _on_recruit_response(response):
	gui.dialogue(response)
	response.connect("completed", self, "_on_recruit_completed")

func _on_recruit():
	print("recruit option selected in menu")
	var target = entity_at($select.tile)
	$select.disable()
	if get_current().character.turn_limits.actions != 0 and is_adjacent(get_current(), target):
		var recruitment = Recruitment.new(target.character)
		gui.dialogue(recruitment.intro)
		recruitment.connect("response", self, "_on_recruit_response")

func _on_guard():
	if get_current().character.turn_limits.actions != 0:
		get_current().guard()
	gui.call_deferred("back")

func _on_heal():
	var target = entity_at($select.tile)	
	if get_current().character.turn_limits.actions != 0:
		var healed = get_current().heal(target)
		var damage_feedback:Node = load("res://scenes/damage_feedback.tscn").instance()
		damage_feedback.position.x = target.position.x
		damage_feedback.position.y = target.position.y - 3
		damage_feedback.get_node("damage").text = "+" + str(healed)
		add_child(damage_feedback)
		target.get_node("vfx/heal").emitting = true
		print("healed")
	gui.call_deferred("back")

func _on_end():
	gui.call_deferred("back")
	print("explicit end request, advancing turn")
	get_current().character.turn_limits.move_distance = 0
	get_current().character.turn_limits.actions = 0
	get_current().get_node("done").show()
	get_current().is_done = true
	advance_turn()

func _accept_loot(item):
	if item.equipment_slot == Item.SLOT.ATK:
		get_current().character.item_atk = item
	else:
		get_current().character.item_def = item
	gui.get_node("sfx/select").play()
	gui.back()
	

func _destroy_loot():
	gui.get_node("sfx/close").play()
	gui.back()
	
func check_battle():
	$gui/battle.update_stats()

func _on_selector_moved(tile):
	print("$select moved to ", tile)
	var context = get_current_context(tile)
	print(context)
	var target = entity_at($select.tile)
	if current_turn == Game.CONTROL.PLAYER:
		if target and !target.is_loot and !target.is_trigger and target.character.control == Game.CONTROL.AI and context == Game.CONTEXT.ATTACK:
			print("you are pointing on " + str(target.character.name))
			gui.battle(get_current(), target)
		else:
			gui.battle_hide(get_current())
		if target and !target.is_loot and !target.is_trigger and !target.character.control == Game.CONTROL.AI and context == Game.CONTEXT.GUARD and !gui.active:
			print("you are pointing on yourself : " + str(target.character.name))
			gui.ally(get_current())
		else:
			gui.ally_hide(get_current())
	var current_path = pathfinder.find_path(get_current().tile, $select.tile)
	if current_path.size() > 0:
		if context == Game.CONTEXT.MOVE:
			$path_preview.preview_path(current_path)
		elif context == Game.CONTEXT.NOT_ALLOWED:
			$path_preview.preview_path(current_path, false)
		else:
			$path_preview.hide_path()
	else:
		$path_preview.hide_path()
	$select.set_context(context)

func get_current_context(tile):
	if Game.level == 0 or gui.get_node("dialogue").visible:
		return Game.CONTEXT.NOT_PLAYABLE
	if $select.mode == $select.MODE.CHECK_MAP:
		return Game.CONTEXT.NEUTRAL
	var unit = entity_at(tile)
	if unit:
		if unit.is_loot or unit.is_trigger:
			return Game.CONTEXT.USE
		elif unit.character.control == Game.CONTROL.AI:
			return Game.CONTEXT.ATTACK
		elif get_current().character.has_ability(Game.ABILITY.HEAL):
			return Game.CONTEXT.HEAL
		elif get_current() == unit:
			return Game.CONTEXT.GUARD
		else:
			return Game.CONTEXT.NEUTRAL
	if not current[current_turn].empty():
		print(current_character)
		var current_path = pathfinder.find_path(get_current().tile, $select.tile)
		if current_path.size() > 0:
			var allowed = current_path.size() <= get_current().character.turn_limits.move_distance
			if all_enemies_eliminated():
				allowed = true
			if not allowed:
				return Game.CONTEXT.NOT_ALLOWED
	else:
		return Game.CONTEXT.NOT_PLAYABLE
	return Game.CONTEXT.MOVE

# DEBUG INPUT
#func _input(event):
#	if event.is_action("ui_focus_next") && !event.is_echo() && event.is_pressed():
#		_on_next_level()
#	if event.is_action("ui_home") && !event.is_echo() && event.is_pressed():
#		_on_replay()
#	if event.is_action("ui_page_down") && !event.is_echo() && event.is_pressed():
#		var additional_character = load("res://resources/ogre.tres")
#		additional_character.control = Game.CONTROL.PLAYER
#		Game.team.append(additional_character)
#		print("The OGRE has joined the team!")
#	if event.is_action("cheat_kill_everyone") && !event.is_echo() && event.is_pressed():
#		for unit in current[Game.CONTROL.AI]:
#			unit.die()
#
