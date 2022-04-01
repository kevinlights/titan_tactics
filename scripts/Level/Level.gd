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

func _attach_story():
	var story_filename = "res://resources/story/" + Game.language + "/level" + str(Game.level + 1) + ".json";
	story_executor = StoryExecutor.new(world, gui, selector)
	story_executor.load_story(story_filename)

func _overlay(progress, color):
	var ml = $Spatial/terrain.mesh_library
	var _targetColor = color
	var colorval = 1 - (((200 / 100) * progress) / 255) #0..1
	for i in ml.get_item_list():
		var name = ml.get_item_name(i)
		if name != 'Water':
			ml.get_item_mesh(i).surface_get_material(0).set("albedo_color",Color(colorval,colorval,colorval))

func return_control():
	logger.info("return control")
	gui.back()
	selector.enable()
