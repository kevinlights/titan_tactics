class_name Level
extends Node

export(String) var add_character
export(String) var remove_character
export(String) var map_node = "SINGLE"

onready var world = get_tree().get_root().get_node("World")
onready var gui = get_tree().get_root().get_node("World/gui")
onready var selector = get_tree().get_root().get_node("World/select")

var story = {}
var story_executor

var logger = Logger.new("Level")

func _ready():
	world.connect("win", self, "_on_end_level")
	world.connect("level_start", self, "_on_start_level")

	if add_character and add_character != "":
		var characters = add_character.split(",")
		for add_char in characters:
			var additional_character = load("res://resources/cast/" + add_char + ".tres")
			additional_character.control = TT.CONTROL.PLAYER
			Game.add_to_team(additional_character)
	if remove_character and remove_character != "":
		var found = null
		for character in Game.team:
			if character.name.nocasecmp_to(remove_character) == 0:
				found = character
				break
		if found:
			Game.team.erase(found)
	_attach_story()
	# _collect_materials()

func _attach_story():
	var story_filename = "res://resources/story/level" + str(Game.level + 1) + ".json";
	story_executor = StoryExecutor.new(world, gui, selector)
	story_executor.load_story(story_filename)
	# var file = File.new()
	# if file.file_exists(story_filename):
	# 	file.open(story_filename, File.READ)
	# 	var data = parse_json(file.get_as_text())
	# 	for item in data:
	# 		story[item.trigger] = Story.new(item.story)
	# 		story[item.trigger].id = item.trigger
	# 		story[item.trigger].connect("dialogue", self, "_on_dialogue")
	# 		story[item.trigger].connect("start", self, "_on_story_start")
	# 		story[item.trigger].connect("end", self, "_on_story_end")
	# 		story[item.trigger].connect("attack", self, "_on_attack")
			# action signals to connect
			# signal attack(target)
			# signal despawn(target)
			# signal dialogue(avatar, message)
			# signal emote(target)
			# signal expect(target)
			# signal face(target)
			# signal focus(target)
			# signal hint(target)
			# signal move(target)
			# signal music(target)
			# signal select(target)
			# signal spawn(target)
			# signal win
	# 		world.connect("story", self, "_on_story")
	# else:
	# 	logger.info("Can't find story file for level: ", story_filename)

# func _collect_materials():
# 	#var ml = $Spatial/terrain.mesh_library
# 	#for i in ml.get_item_list():
# 	#	ml.get_item_mesh(i).surface_get_material(0).set("albedo_color","#ff00ff")
# 	#save material
# 	pass

func _overlay(progress, color):
	var ml = $Spatial/terrain.mesh_library
	var _targetColor = color
	var colorval = 1 - (((200 / 100) * progress) / 255) #0..1
	for i in ml.get_item_list():
		var name = ml.get_item_name(i)
		if name != 'Water':
			ml.get_item_mesh(i).surface_get_material(0).set("albedo_color",Color(colorval,colorval,colorval))

func _on_story(trigger):
	logger.info("_on_story ", trigger)
	if trigger in story and !story[trigger].consumed:
		story[trigger].play()
		# logger.info("have trigger ", trigger)
		# gui.start("dialogue_box", story[trigger])

func _on_start_level():
	logger.info("start level")
	if "start" in story:
		logger.info_debug(story.start.id, story.start.messages.size())
		gui.start("dialogue_box", story.start)
#	if start_dialogue:
#		gui.start("dialogue_box", start_dialogue)

func _on_end_level():
	logger.info("dialog end level check")
	if "end" in story and !story.end.consumed:
		gui.start("dialogue_box", story.end)

func _on_dialogue(avatar, text):
	gui.start("dialogue_box", avatar, text)

func _on_story_start():
	world.range_overlay.hide()

func _on_attack(target):
	pass

func return_control():
	logger.info("return control")
	gui.back()
	selector.enable()
