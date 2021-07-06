class_name StoryExecutor
extends Node

var world
var gui # = get_tree().get_root().get_node("World/gui")
var selector # = get_tree().get_root().get_node("World/select")

var story = {}
var logger
var current = null
var skip_events = false
var event_will_progress = true

func _init(story_world, story_gui, story_selector):
	logger = Logger.new("StoryExecutor")
	logger.info("Initialize")
	world = story_world
	gui = story_gui
	selector = story_selector
	var err = world.connect("story", self, "_on_story")
	if err:
		logger.error(err)
	err = world.connect("win", self, "_on_end_level")
	if err:
		logger.error(err)
	err = world.connect("level_start", self, "_on_start_level")
	if err:
		logger.error(err)
	gui.get_node("dialogue_box").connect("completed", self, "advance")

func load_story(story_filename:String):
	var file = File.new()
	if file.file_exists(story_filename):
		file.open(story_filename, File.READ)
		var data = parse_json(file.get_as_text())
		for item in data:
			story[item.trigger] = Story.new(item.story)
			story[item.trigger].id = item.trigger
			story[item.trigger].connect("attack", self, "_on_attack")
			story[item.trigger].connect("despawn", self, "_on_despawn")
			story[item.trigger].connect("dialogue", self, "_on_dialogue")
			story[item.trigger].connect("emote", self, "_on_emote")
			story[item.trigger].connect("end", self, "_on_story_end")
			story[item.trigger].connect("expect", self, "_on_expect")
			story[item.trigger].connect("face", self, "_on_face")
			story[item.trigger].connect("hint", self, "_on_hint")
			story[item.trigger].connect("select", self, "_on_select")
			story[item.trigger].connect("spawn", self, "_on_spawn")
			story[item.trigger].connect("start", self, "_on_story_start")
			story[item.trigger].connect("win", self, "_on_win")
			story[item.trigger].connect("move", self, "_on_move")
			story[item.trigger].connect("focus", self, "_on_focus")

		logger.info("Story attached")
	else:
		logger.info("Failed to load story file")

func advance():
	if current != null:
		logger.info("Advance")
		current.advance()
	else:
		logger.info("No story to advance")

func _on_dialogue(story_message):
	logger.info("Dialogue event ", story_message)
	gui.start("dialogue_box", story_message)

func _on_story(trigger):
	logger.info("_on_story ", trigger)
	if trigger in story and !story[trigger].consumed:
		current = story[trigger]
		story[trigger].play()

func _on_focus(target) -> void:
	var marker = world.find_story_marker(target)
	if not marker:
		marker = world.find_character(target)
	world.get_node("lookat/camera").track(marker)
	advance()

func _on_move(target) -> void:
	var target_character = world.find_character(target)
	var marker = world.find_story_marker(target)
	var character = world.get_current()
	var path = PoolVector3Array()
	if target_character:
		path = world.pathfinder.find_path(character.translation, target_character.translation, world.get_blocked_cells())
		path.resize(path.size() - 1)
	elif marker:
		path = world.pathfinder.find_path(character.translation, marker.translation, world.get_blocked_cells())
	character.connect("path_complete", self, "advance", [], CONNECT_ONESHOT)
	var instant = false
	if skip_events == true:
		instant = true
	character.move(path, true, instant)


# > win
func _on_win() -> void:
	world.game_over = true
	world.emit_signal("win")
	world.call_deferred("_on_win")

# > hint <story_marker>
func _on_hint(target) -> void:
	var marker = world.find_story_marker(target)
	if marker:
		world.range_overlay.set_hint_tile(marker.translation)
	else:
		world.range_overlay.set_hint_tile(null)
	advance()

func _on_story_start():
	selector.disable()
	world.get_node("gui/skiptip").visible = true
	world._on_cutscene()
	if world.pathfinder != null && world.pathfinder.overlay != null:
		world.pathfinder.overlay.visible = false

func _on_story_end():
	logger.info("Cutscene end")
	world.get_node("gui/skiptip").visible = false
	world._on_end_cutscene()
	world.get_node("lookat/camera").track(selector)
	if world.pathfinder != null && world.pathfinder.overlay != null:
		world.pathfinder.overlay.visible = true
	world.current_turn = TT.CONTROL.PLAYER
	selector.enable()
	# try triggering queued ui
	gui.next()

func _on_attack_done(_arrow, target_character):
	world.get_node("lookat/camera").track(target_character)
	print("[DialogBox] Attack done - advancing.")
	if event_will_progress or skip_events:
		advance()

func _on_attack(target) -> void:
	if skip_events:
		_on_attack_done(null,null)
		return

	var name_direction = target.split(".")
	var target_character = world.find_character(name_direction[0])
	if !target_character:
		logger.warning("cannot find character", name_direction[0])
		return
	var target_target = world.find_story_marker(name_direction[1])
	if !target_target:
		logger.warning("cannot find story marker", name_direction[1], "trying for direction")
		# would have left this as left/right/etc but >face already uses west/east/etc
		if name_direction[1] in [ "west", "east", "north", "south" ]:
			var nwse = {
				"west": "left",
				"east": "right",
				"north": "up",
				"south": "down"
			}
			target_character.avatar.play("attack-" +  target_character.directions[Game.camera_orientation][nwse[name_direction[1]]])
			yield(get_tree().create_timer(1.0),"timeout")
			advance()
			return
		else:
			logger.warning(name_direction[1], "does not match east/west/north/south")
			return
	if target_character.character.character_class == TT.TYPE.ARCHER:
		var arrow = load("res://scenes/arrow.tscn").instance()
		world.add_child(arrow)
		world.get_node("lookat/camera").track(arrow)
		arrow.connect("hit", self, "_on_attack_done", [arrow, target_character], CONNECT_ONESHOT)
		arrow.fire(target_character.translation,target_target.translation)

func _on_spawn(target) -> void:
	world.surprise_spawn(target)
	advance()

func _on_despawn(target) -> void:
	var target_character = world.find_character(target)
	if target_character:
		target_character.despawn()
	else:
		logger.warning("Error - can't despawn", target)
	advance()

# > select <character>
func _on_select(target) -> void:
	var charTarget = world.find_character(target)
	world.get_node("lookat/camera").track(charTarget)
	world.select_by_name(target)
	advance()

func _emote_done(_emote_source):
	if event_will_progress or skip_events:
		advance()

func _on_emote(target):
	if skip_events:
		_emote_done(null)
		return
	var name_emote = target.split(".")
	var target_character = world.find_character(name_emote[0])
	if target_character:
		target_character.connect("emote_finished",self, "_emote_done", [target_character], CONNECT_ONESHOT)
		target_character.emote(name_emote[1])
	else:
		logger.error("invalid target character: " + name_emote[0])
		_emote_done(target_character)

func _on_face(target) -> void:
	var name_direction = target.split(".")
	var target_character = world.find_character(name_direction[0])
	if target_character:
		target_character.face(name_direction[1])
	else:
		logger.error("invalid target character: " + name_direction[0])
	advance()

func _on_expect(target) -> void:
	world.expected_target = world.find_story_marker(target)
	advance()

func _on_start_level():
	logger.info("start level")
	if "start" in story:
		logger.info(story.start.id, story.start.messages.size())
		_on_story("start")
		# story.start.play()
		# gui.start("dialogue_box", story.start)
#	if start_dialogue:
#		gui.start("dialogue_box", start_dialogue)

func _on_end_level():
	logger.info("dialog end level check")
	if "end" in story and !story.end.consumed:
		_on_story("end")
		# gui.start("dialogue_box", story.end)
