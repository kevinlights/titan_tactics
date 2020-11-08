extends Spatial

signal win
signal auto_deployed
#signal all_enemies_eliminated

onready var gui = get_tree().get_root().get_node("World/gui")
onready var range_overlay = $range_overlay

var tile_meta
var world_map
var game_over = false
var current_turn = TT.CONTROL.PLAYER
var player_spawns = []
var pathfinder
var ai
var current_character = 0
var turns = 0
var map_size = { "width": 10, "height": 10 }

var num_done = 0

var current = {
	TT.CONTROL.AI: [],
	TT.CONTROL.PLAYER: []
}

func load_level(level_name):
	print("Loading level " + level_name)
	var level = load("res://scenes/levels/" + level_name + ".tscn").instance()
	add_child_below_node($map_anchor, level)
	world_map = level.get_node("map")
	# NOTE: If the below errors:
	# - please check that the level's node has the level.gd script attached
	# - please check the script's variables are set correctly	
	var _3d_map = level.get_node("Spatial").get_node(level.map_node)
	pathfinder = _3d_map
	$range_overlay.set_gridmap(_3d_map)
	$select.disable()

func get_current():
	current_character = clamp(current_character, 0, abs(current[current_turn].size()-1))
	return current[current_turn][current_character]

func get_blocked_cells():
	var blocked_cells = []
	var characters = get_tree().get_nodes_in_group ("characters")
	for character in characters:
		if not character.is_dead:
			blocked_cells.push_back(character.tile)
	return blocked_cells

func entity_at(position_vector):
	var characters = get_tree().get_nodes_in_group ("characters")
	for character in characters:
		if character.tile.x == position_vector.x and character.tile.z == position_vector.z and not character.is_dead:
			return character
	return null

func as_world_position(tile):
	return Vector2(tile.x * TT.cell_size, tile.y * TT.cell_size)

func is_cover_between(character, end):
	var ray = character.get_node("ranged_weapon")
	ray.cast_to = character.to_local(end)
	ray.force_raycast_update()
	print("is cover between ", ray.is_colliding())
	return ray.is_colliding()
	# return false

func spawn_cover(tile):
	var cover = load("res://scenes/cover_tile.tscn").instance()
	cover.position = tile * Vector2(TT.cell_size, TT.cell_size)
	print('world_map.add_child(cover)', cover)
	world_map.add_child(cover)
	print("Spawned cover")
	return cover
	
func spawn_chest(x, y, item_spawner):
	var chest = load("res://scenes/chest.tscn").instance()
	chest.teleport(x, y)
	chest.item_spawner = item_spawner
	chest.add_to_group("characters")
	print('world_map.add_child(chest)', chest)
	world_map.add_child(chest)
	print("Spawned chest")
	return chest

func spawn_character(x, y, type = TT.TYPE.MAGE, control = TT.CONTROL.PLAYER):
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	character.init(type, control)
	character.teleport(x, y)
	character.add_to_group("characters")
	print('world_map.add_child(character) #1', character)
	world_map.add_child(character)
	return character

func _on_modal_resume():
#	gui.paused = false
	if current_turn == TT.CONTROL.PLAYER:
		$select.enable()

func resume():
#	gui.paused = false
	gui.back()
	if current_turn  == TT.CONTROL.AI:
		print("resume ai turn")
#		gui.modal = true
		ai.play()
	else:
		if not game_over:
			print("resume player turn")
#			gui.modal = false
			$select.enable()

func check_end_turn():
	print("check end turn")
	num_done = 0
	for character_check in current[current_turn]:
		if character_check.is_done:
			num_done += 1
	if num_done == current[current_turn].size():
		print("End turn")
		return true
	return false

func advance_turn(explicit = 1, direction = 1):
	if game_over:
		return
	if check_end_turn():
		end_turn()
		return
	next_character(direction)
	while current[current_turn][current_character].is_done or current[current_turn][current_character].is_dead:
		next_character(direction)
		
	print("Advance turn")
	$select.set_origin(get_current())
	if current_turn == TT.CONTROL.PLAYER:
		$range_overlay.set_origin(get_current())
  
	if explicit == 1:
		$select.disable()
		yield(get_tree().create_timer(1.0), "timeout")
	if current_turn  == TT.CONTROL.AI:
		#gui.modal = true
		ai.play()
	elif explicit == 1:
		if not game_over:
			#gui.modal = false
			print("explicit enable")
			$select.enable()
	current_character = clamp(current_character, 0, current[current_turn].size() -1)

func find_story_marker(name):
	var markers = get_tree().get_nodes_in_group("story_markers")
	for marker in markers:
		if marker.marker_name == name:
			return marker
	
func find_character(name):
	for team in [ TT.CONTROL.AI, TT.CONTROL.PLAYER ]:
		for character in current[team]:
			print(character.character.name)
			if character.character.name.to_lower() == name.to_lower():
				return character

func select_by_name(name):
	for team in [ TT.CONTROL.AI, TT.CONTROL.PLAYER ]:
		var index = 0
		for character in current[team]:
			print(character.character.name)
			if character.character.name.to_lower() == name.to_lower():
				current_turn = team
				current_character = index
				return index
			index += 1
	
func next_character(direction):
	current_character += direction
	if current_character >= current[current_turn].size():
		current_character = 0
	if current_character < 0:
		current_character = current[current_turn].size() - 1

func change_character():
	$gui.swap()

func end_turn():
#	gui.back()
	for character in current[TT.CONTROL.PLAYER]:
		character.is_done = false
		character.get_node("done").hide()
		
	current_turn = TT.CONTROL.AI if current_turn == TT.CONTROL.PLAYER else TT.CONTROL.PLAYER
	for character in current[current_turn]:
		character.end_turn()
	current_character = 0
	if current_turn == TT.CONTROL.AI:
		gui.start("enemyturn")
	else:
		gui.start("playerturn")
#	gui.turn(current_turn)
#	$select.disable()

func to_world_path(path):
	var world_path = PoolVector3Array()
	for point in path:
		world_path.append(point) # * Vector2(TT.cell_size, TT.cell_size))
	return world_path

func action():
	print ("world action")
	if game_over:
		return
	var context = get_current_context($select.tile)
	var target = entity_at($select.tile)
	match(context):
		TT.CONTEXT.ATTACK:
			if get_current().character.turn_limits.actions > 0:
				if get_current().can_attack(target):
					if target.can_recruit() and is_adjacent(get_current(), target):
						gui.attack()
					else:
						_on_attack()
		TT.CONTEXT.USE:
			if is_adjacent(target, get_current()):
				if target.is_loot:
					var loot = target.open(get_current().character.character_class)
					if loot:
						yield(get_tree().create_timer(1.0), "timeout")
						print("item " + str(loot.name))
						if target.item_spawner.equipment_slot == 0:
							gui.start("weaponswap", [ get_current().character.item_atk, loot, 0 ])
#							gui.loot(get_current().character.item_atk, loot, 0)
						if target.item_spawner.equipment_slot == 1:
							gui.start("weaponswap", [ get_current().character.item_def, loot, 1 ])
#							gui.loot(get_current().character.item_def, loot, 1)
				else:
					if target.available == "level_complete":
						if all_enemies_eliminated():
							target.use()
					else:
						target.use()
		TT.CONTEXT.MOVE:
			var current_path = pathfinder.find_path(get_current().tile, $select.tile, get_blocked_cells())
			get_current().move(current_path) # to_world_path(current_path))
		TT.CONTEXT.NOT_ALLOWED:
			$gui/sfx/denied.play()
#		TT.CONTEXT.GUARD:
#			print("guard action")
#			if get_current().character.turn_limits.actions == 0:
#				gui.call_deferred("confirm_end_turn")
#			else:
#				gui.guard()
		TT.CONTEXT.HEAL:
			if get_current().character.turn_limits.actions == 0:
#				_on_end()
				gui.start("action_menu", "end")
			else:
				gui.start("action_menu", "heal")
	$range_overlay.set_origin(get_current())

func _on_confirm_end_turn():
	get_current().is_done = true
	_on_end()

func is_adjacent(one, two):
	print("is adjacent ", one.tile, " ", two.tile)
	return (abs(one.tile.x - two.tile.x) <= 1 and abs(one.tile.z - two.tile.z) == 0) or (abs(one.tile.x - two.tile.x) == 0 and abs(one.tile.z - two.tile.z) <= 1)

func _ready():
	print(Game.team)
	randomize()
	
	load_level(Game.get_level())
	current[TT.CONTROL.PLAYER] = []
	current[TT.CONTROL.AI] = []
	player_spawns = []

	var player_spawn_nodes = get_tree().get_nodes_in_group("player_spawns")
	for player_spawn_node in player_spawn_nodes:
		player_spawns.append(player_spawn_node.translation) # Vector(player_spawn_node.translation.x, player_spawn_node.translation.z))
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
#	gui.get_node("lvlup").connect("close", self, "check_end_turn")
	gui.get_node("lvlup").connect("close", self, "_on_dialogue_complete")
	gui.get_node("win").connect("next", self, "_on_next_level")
	gui.get_node("win").connect("retry", self, "_on_replay")
	gui.get_node("lose").connect("retry", self, "_on_replay")
	gui.get_node("lose").connect("quit", self, "_on_quit")
	gui.get_node("pause").connect("resume", self, "resume")
#	gui.connect("modal_closed", self, "_on_modal_resume")
	gui.get_node("endturn").connect("confirm_end_turn", self, "_on_confirm_end_turn")
	$select.connect("moved", self, "_on_selector_moved")

	call_deferred("select_team")
	#$cutscene_music.get_node(Game.get_theme()).play()
	$music.get_node(Game.get_theme()).play()
	call_deferred("spawn_ai_team")
	call_deferred("spawn_chests")
	$lookat/camera.track($select)

func spawn_chests():
	var chest_spawns = get_tree().get_nodes_in_group("chest_spawns")
	for chest_spawn in chest_spawns:
		var chest = spawn_chest(
			floor(chest_spawn.translation.x / TT.cell_size), 
			floor(chest_spawn.translation.z / TT.cell_size),
			chest_spawn.item_spawner)
		chest_spawn.hide()

func surprise_spawn(spawn_trigger):
	print("Surprise spawns! ", spawn_trigger)
	var ai_spawns = get_tree().get_nodes_in_group("ai_spawns")
	for ai_spawn in ai_spawns:
		if ai_spawn.spawn_trigger == spawn_trigger:
			print("Spawning surprise enemy")
			spawn_ai_character(ai_spawn, true)
			yield(get_tree().create_timer(0.5), "timeout")

func spawn_ai_character(ai_spawn, surprise = false):
	ai_spawn.has_spawned = true
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	character.from_spawner(ai_spawn, surprise)
	character.teleport(ai_spawn.translation.x, ai_spawn.translation.z)
#	print("Control: ", character.character.control)
#	if !character.character.control:
#		character.character.control = TT.CONTROL.AI
	character.add_to_group("characters")
	current[character.character.control].append(character)
	character.connect("done", self, "advance_turn")
	character.connect("path_complete", $select, "update_context")
	character.connect("death", self, "_on_death")
	if character.character.control == TT.CONTROL.AI:
		character.connect("dialogue", self, "_on_dialogue")
	else:
		character.connect("path_complete", self, "check_move_triggers", [ character ])
		character.connect("attack_complete", self, "_on_attack_complete")
		character.character.connect("level_up", self, "_on_level_up")
		character.character.reset_turn()
	print('world_map.add_child(character) #2', character)
	world_map.add_child(character)
	
func spawn_ai_team():
	var ai_spawns = get_tree().get_nodes_in_group("ai_spawns")
	for ai_spawn in ai_spawns:
		if ai_spawn.spawn_trigger == "" or ai_spawn.spawn_trigger == "level_start":
			spawn_ai_character(ai_spawn)
		ai_spawn.hide()
	ai = SmortAI.new(self)
	
func select_team():
	for member in Game.team:
		member.hp = member.max_hp
		member.reset_turn() # reset actions and moves
	$select.translation = player_spawns[0] + Vector3(0.5, 0.5, -0.5);
	$select.translation.y = 0.2
	if Game.team.size() > 1:
		gui.start("characterselect")
		$gui/characterselect.set_spawn(player_spawns[0])
	else:
		auto_deploy_only_character()

func _on_attack_complete():
	$select.capture_camera()
	if current_turn == TT.CONTROL.PLAYER:
		$range_overlay.set_origin(get_current())

func _on_dialogue_complete(content):
	# gui.back()
	print("character triggered dialogue complete")
#	if not check_end_game():
#		$select.enable()

func _on_dialogue(content):
	if "messages" in content:
		content.connect("completed", self, "_on_dialogue_complete")
		gui.start("dialogue_box", content)

func _on_team_select_done():
	print("team select confirm")
	gui.start("teamconfirm")
	gui.back()
#	gui.get_node('characterselect').dismiss()

func _on_check_map():
	gui.back()
	#gui.get_node("sfx/select").play()
	$select.mode = $select.MODE.CHECK_MAP
	print("check map enable selector")
	$select.call_deferred("enable")

func _on_edit_team():
	# rediscover player spawns
	player_spawns = []
	var player_spawn_nodes = get_tree().get_nodes_in_group("player_spawns")
	for player_spawn_node in player_spawn_nodes:
		player_spawns.append(player_spawn_node.translation)
	# clear previously selected team
	for character in current[TT.CONTROL.PLAYER]:
		world_map.remove_child(character)
	current[TT.CONTROL.PLAYER].resize(0)
	# and start over
	gui.back()
	call_deferred("select_team")

func _on_start_level():
#	gui.modal = false
	gui.back()
	#gui.get_node("sfx/select").play()
	$select.mode = $select.MODE.PLAY
	$select.set_origin(get_current())
	print("start level")
	$select.call_deferred("enable")
	$range_overlay.call_deferred("set_origin", get_current())

func _on_win():
#	gui.get_node("dialogue_box").hide()
	if Game.level + 1 < Game.get_level_count():
		gui.start("win")
	else:
		get_tree().change_scene("res://scenes/landing.tscn")
	$music/win.play()
	print("End game: WIN")

func _on_quit():
	get_tree().change_scene("res://scenes/landing.tscn")

func all_enemies_eliminated():
	var ai_spawns = get_tree().get_nodes_in_group("ai_spawns")
	for spawn in ai_spawns:
		if not spawn.has_spawned:
			return false
	return current[TT.CONTROL.AI].size() == 0

func check_end_game():
	if game_over:
		return
#	if all_enemies_eliminated():
#		emit_signal("all_enemies_eliminated")
#		var triggers = get_tree().get_nodes_in_group ("dialogue_triggers")
#		for trigger in triggers:
#			print("Available ", trigger.available)
#			print("Consumed ", trigger.consumed)
#			if trigger.available == "level_complete" and !trigger.consumed:
#				return false

	for control in [ TT.CONTROL.AI, TT.CONTROL.PLAYER ]:
		if current[control].size() == 0:
			if control == TT.CONTROL.AI and !all_enemies_eliminated():
				return false
			game_over = true
			$select.disable()
			gui.call_deferred("battle_hide")
			if control == TT.CONTROL.AI:
				emit_signal("win")
				call_deferred("_on_win")
			else:
				gui.start("lose") #lose()
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
  SaveLoadSystem.save_game()
  get_tree().reload_current_scene()

func _on_next_level():
	if Game.level + 1 < Game.get_level_count():
		Game.level += 1
		if Game.level > Game.unlocked_level:
			Game.unlocked_level = Game.level
		SaveLoadSystem.save_game()
		get_tree().reload_current_scene()
	else:
		# All levels completed?
		SaveLoadSystem.save_game()
#		gui.back()
		gui.credits()
		$music.get_node(Game.get_theme()).stop()
		$music/win.play()

func same_tile(tile1, tile2):
	var tile1_floor = Vector3(floor(tile1.x), 0, floor(tile1.z))
	var tile2_floor = Vector3(floor(tile2.x), 0, floor(tile2.z))
	return tile1_floor.is_equal_approx(tile2_floor)

func check_move_triggers(character):
	var markers = get_tree().get_nodes_in_group("story_markers")
	for marker in markers:
		if marker.dialogue and same_tile(marker.translation, character.translation): #marker.translation.is_equal_approx(character.translation):
			if not marker.dialogue.consumed:
				marker.dialogue.connect("completed", self, "_on_dialogue_complete")
				gui.start("dialogue_box", marker.dialogue)
#				gui.dialogue(marker.dialogue)
				break

func auto_deploy_only_character():
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	var spawn = player_spawns.pop_front()
	character.from_library(Game.team[0])
	character.teleport(floor(spawn.x), floor(spawn.z - 1))
	character.add_to_group("characters")
	print("Player spawn ", spawn)
	print('world_map.add_child(character) #3', character)
	world_map.add_child(character)
	current[TT.CONTROL.PLAYER].append(character)
	character.connect("done", self, "advance_turn")
	character.connect("death", self, "_on_death")
	character.connect("path_complete", self, "check_move_triggers", [ character ])
	character.connect("path_complete", $select, "update_context")
	character.connect("attack_complete", self, "_on_attack_complete")
	character.character.control = TT.CONTROL.PLAYER
	character.character.connect("level_up", self, "_on_level_up")
	_on_start_level()
	emit_signal("auto_deployed")

func _on_select_team_member(team_member):
	var character:Node = load("res://scenes/character_controller.tscn").instance()
	var spawn = player_spawns.pop_front()
	character.from_library(team_member)
	character.teleport(floor(spawn.x), floor(spawn.z - 1))
	character.add_to_group("characters")
	print('world_map.add_child(character) #3', character)
	world_map.add_child(character)
	current[TT.CONTROL.PLAYER].append(character)
	character.connect("done", self, "advance_turn")
	character.connect("death", self, "_on_death")
	character.connect("path_complete", self, "check_move_triggers", [ character ])
	character.connect("path_complete", $select, "update_context")
	character.connect("attack_complete", self, "_on_attack_complete")
	character.character.control = TT.CONTROL.PLAYER
	character.character.connect("level_up", self, "_on_level_up")
	if player_spawns.size() > 0:
		$select.tile = player_spawns[0]
		$gui/characterselect.set_spawn(player_spawns[0])
	else:
		_on_team_select_done()

func _on_level_up(diff, character):
#	gui.call_deferred("level_up", diff, character)
	gui.start("lvlup", [ diff, character ])
#	gui.level_up(diff, character)

func _initiate_turn():
	# in case a signal triggers this after the level is won/lost
	if current[TT.CONTROL.AI].size() == 0 or current[TT.CONTROL.PLAYER].size() == 0:
		print("Don't initiate turn; the game is already over.")
		return
	for character in current[current_turn]:
		character.apply_effects()
	print("initiate turn")
#	gui.back()
	$select.enable()
	$select.set_origin(get_current())
	$select.set_context(get_current_context($select.tile))
	if current_turn == TT.CONTROL.PLAYER:
		$range_overlay.set_origin(get_current())
	if current_turn == TT.CONTROL.AI:
		print("Control turned over to AI")
#		gui.modal = true
		ai.play()
		$range_overlay.set_origin(null)
	
func _on_attack():
	print("attack option selected in menu")
	if get_current().character.turn_limits.actions != 0:
		var target = entity_at($select.tile)
		if get_current().character.character_class != TT.TYPE.FIGHTER and is_cover_between(get_current(), target.translation):
#			gui.error("BLOCKED LINE OF SIGHT")
#			gui.call_deferred("back")
			return
		var damage = get_current().attack(target)

#		gui.call_deferred("close_attack")
#		gui.back()
#		yield(get_tree().create_timer(2.0), "timeout")
#		gui.call_deferred("battle_hide")
		
#	else:
#		gui.back()
#		gui.error("NO MORE ACTIONS")
#		gui.call_deferred("back")

func _on_recruit_completed(id):
	print("recruitment completed ", id)
#	gui.back()
	var target = entity_at($select.tile)
	get_current().character.turn_limits.actions -= 1
	if id == "accepted":
		target.recruit(get_current())
		target.character.control = TT.CONTROL.PLAYER
		Game.team.append(target.character)
		current[TT.CONTROL.AI].erase(target)
	else:
		target.recruit_failed(get_current())
		gui.error("FAILED TO RECRUIT")
	$select.go_home()
	$select.call_deferred("enable")

func _on_recruit_response(response):
	response.connect("completed", self, "_on_recruit_completed")
	print("set response dialog ", response.messages[0].message)
	gui.dialogue(response)

func _on_recruit():
	print("recruit option selected in menu")
	var target = entity_at($select.tile)
	$select.disable()
	if get_current().character.turn_limits.actions != 0 and is_adjacent(get_current(), target):
		var recruitment = Recruitment.new(target.character, target.character.personality)
		print("recruit dialog intro")
		gui.dialogue(recruitment.intro)
		gui.answers(recruitment)
		recruitment.connect("response", self, "_on_recruit_response")
		recruitment.connect("completed", self, "_on_recruit_completed")

func _on_guard():
#	gui.back()
	if get_current().character.turn_limits.actions != 0:
		get_current().guard()


func _on_heal():
	var target = entity_at($select.tile)
	if get_current().character.turn_limits.actions != 0:
		var healed = get_current().heal(target)

		var damage_feedback:Node = load("res://scenes/damage_feedback.tscn").instance()
		var feedback_position = get_node("lookat/camera").unproject_position(target.translation + Vector3(.5, .5, .5))
		damage_feedback.position = feedback_position
		damage_feedback.get_node("damage").text = "+" + str(healed)
		print('add_child(damage_feedback)', damage_feedback)
		add_child(damage_feedback)
#
#		var damage_feedback = load("res://scenes/damage_feedback.tscn").instance()
#		damage_feedback.translation.x = target.translation.x
#		damage_feedback.translation.z = target.translation.z
#		damage_feedback.get_node("damage").text = "+" + str(healed)
#		add_child(damage_feedback)
		target.get_node("vfx/heal").emitting = true
		print("healed")
#	gui.call_deferred("back")

func _on_end():
#	gui.call_deferred("back")
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
	print("current context = ", context, " [", TT.CONTEXT.keys()[context] ,"]")
	var target = entity_at($select.tile)
	if current_turn == TT.CONTROL.PLAYER:
		if target and !target.is_loot and !target.is_trigger and target.character.control == TT.CONTROL.AI and context == TT.CONTEXT.ATTACK:
			print("you are pointing on " + str(target.character.name))
			gui.start("battle", target)
		if target and !target.is_loot and !target.is_trigger and !target.character.control == TT.CONTROL.AI and (context == TT.CONTEXT.GUARD or context == TT.CONTEXT.HEAL):
			print("you are pointing on yourself : " + str(target.character.name))
			gui.start("ally", target) #ally(get_current())
		if context == TT.CONTEXT.MOVE or context == TT.CONTEXT.NOT_ALLOWED:
			print("Closing ui because of context ", context)
			gui.back()
	$range_overlay.set_selector(tile)
	var current_path = pathfinder.find_path(get_current().tile, $select.tile, get_blocked_cells())
	$select.set_context(context)

func play_music(music_node):
	$music.get_node(Game.get_theme()).stop()
	var music = $cutscene_music.get_node(music_node)
	music.play()

func get_current_context(tile):
#	print(Game.level, ", ",  gui.get_node("dialogue").visible)
	if Game.level == 0:
		#return TT.CONTEXT.NOT_PLAYABLE
		pass
	if gui.get_node("dialogue_box").visible:
		return TT.CONTEXT.NOT_PLAYABLE
	if $select.mode == $select.MODE.CHECK_MAP:
		return TT.CONTEXT.NEUTRAL
	var unit = entity_at(tile)
	if unit:
		if unit.is_loot or unit.is_trigger:
			return TT.CONTEXT.USE
		elif unit.character.control == TT.CONTROL.AI:
			return TT.CONTEXT.ATTACK
		elif get_current().character.has_ability(TT.ABILITY.HEAL):
			return TT.CONTEXT.HEAL
		elif get_current() == unit:
			return TT.CONTEXT.GUARD
		else:
			return TT.CONTEXT.NEUTRAL
	if not current[current_turn].empty():
		var current_path = pathfinder.find_path(get_current().tile, tile, get_blocked_cells())
		if current_path.size() > 0:
			var allowed = current_path.size() <= get_current().character.turn_limits.move_distance
			if all_enemies_eliminated():
				allowed = true
			if not allowed:
				return TT.CONTEXT.NOT_ALLOWED
		else:
			return TT.CONTEXT.NOT_ALLOWED
	else:
		return TT.CONTEXT.NOT_PLAYABLE
	return TT.CONTEXT.MOVE

# DEBUG INPUT
func _input(event):
	if event.is_action("ui_focus_next") && !event.is_echo() && event.is_pressed():
		_on_next_level()
	if event.is_action("ui_home") && !event.is_echo() && event.is_pressed():
		_on_replay()
	if event.is_action("pause_game") && !event.is_echo() && event.is_pressed():
		gui.start("pause")
#		gui.pause()
	if event.is_action("ui_page_up") && !event.is_echo() && event.is_pressed():
		Game.level = 10
		get_tree().reload_current_scene()
	if event.is_action("ui_page_down") && !event.is_echo() && event.is_pressed():
		var additional_character = load("res://resources/cast/ogre.tres")
		additional_character.control = TT.CONTROL.PLAYER
		Game.team.append(additional_character)
		print("The OGRE has joined the team!")
	if event.is_action("cheat_kill_everyone") && !event.is_echo() && event.is_pressed():
		for unit in current[TT.CONTROL.AI]:
			unit.die()
	if event.is_action("cheat_suicide") && !event.is_echo() && event.is_pressed():
		for unit in current[TT.CONTROL.PLAYER]:
			unit.die()
	if event.is_action("cheat_log_stats") && !event.is_echo() && event.is_pressed():
		print("selector ", $select.tile)
		print("current character tile ", get_current().tile)
		print("current character translation ", get_current().translation)
	if event.is_action("mute_music") && !event.is_echo() && event.is_pressed():
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	if event.is_action("unmute_music") && !event.is_echo() && event.is_pressed():
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	if event.is_action("context_menu") && !event.is_echo() && event.is_pressed():
		if get_current().character.turn_limits.actions > 0:
			gui.start("action_menu", "guard")
		else:
			gui.start("action_menu", "end")
	if event.is_action("camera_clockwise") && !event.is_echo() && event.is_pressed():
		if not $lookat/camera.is_rotating():
			var new_orientation = Game.camera_orientation + 1
			if Game.camera_orientation == TT.CAMERA.WEST:
				new_orientation = TT.CAMERA.NORTH
			print("Clockwise ", Game.camera_orientation, " ", new_orientation)
			Game.camera_orientation = new_orientation
		
	if event.is_action("camera_counter_clockwise") && !event.is_echo() && event.is_pressed():
		if not $lookat/camera.is_rotating():
			var new_orientation = Game.camera_orientation - 1
			if Game.camera_orientation == TT.CAMERA.NORTH:
				new_orientation = TT.CAMERA.WEST
			print("Counter-Clockwise ", Game.camera_orientation, " ", new_orientation)
			Game.camera_orientation = new_orientation
			
