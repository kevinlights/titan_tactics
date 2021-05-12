class_name Level
extends Node

export(Resource) var start_dialogue
export(Resource) var end_dialogue
export(String) var add_character
export(String) var remove_character
export(String) var map_node = "SINGLE"

onready var world = get_tree().get_root().get_node("World")
onready var gui = get_tree().get_root().get_node("World/gui")
onready var selector = get_tree().get_root().get_node("World/select")

var story = {}

func _ready():
	world.connect("win", self, "_on_end_level")
#	world.connect("auto_deployed", self, "_on_start_level")
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
	_collect_materials()

func _attach_story():
	var story_filename = "res://resources/story/level" + str(Game.level + 1) + ".json";
	var file = File.new()
	if file.file_exists(story_filename):
		file.open(story_filename, File.READ)
		var data = parse_json(file.get_as_text())
		for item in data:
			print(item.trigger)
			print(item.story.size())
			story[item.trigger] = Dialogue.new(item.story)
			story[item.trigger].id = item.trigger
		world.connect("story", self, "_on_story")
	else:
		print("Can't find story file for level: ", story_filename)
	
func _collect_materials():
	#var ml = $Spatial/terrain.mesh_library
	#for i in ml.get_item_list():
	#	ml.get_item_mesh(i).surface_get_material(0).set("albedo_color","#ff00ff")
	#save material
	pass
	
func _overlay(progress, color):
	var ml = $Spatial/terrain.mesh_library
	var targetColor = color
	var colorval = 1 - (((200 / 100) * progress) / 255) #0..1
	for i in ml.get_item_list():
		var name = ml.get_item_name(i)
		if name != 'Water':
			ml.get_item_mesh(i).surface_get_material(0).set("albedo_color",Color(colorval,colorval,colorval))
	
func _on_story(trigger):
	print("_on_story ", trigger)
	if trigger in story and !story[trigger].consumed:
		gui.start("dialogue_box", story[trigger])

func _on_start_level():
	print("start level")
	if "start" in story:
		print_debug(story.start.id, story.start.messages.size())
		gui.start("dialogue_box", story.start)
#	if start_dialogue:
#		gui.start("dialogue_box", start_dialogue)

func _on_end_level():
	print("dialog end level check")
	if "end" in story and !story.end.consumed:
#	if end_dialogue and !end_dialogue.consumed:
		gui.start("dialogue_box", story.end)

#func _on_dialogue_complete(id):
#	print("completed ", id)
#	var followup = false
#	for content in dialogue:
#		var trigger_list = content.trigger_id.split(",")
#		if content.trigger == PT_Dialogue.TRIGGER.DIALOGUE and id in trigger_list: # content.trigger_id == id:
#			print("dialogue trigger content")
#			gui.call_deferred("dialogue", content)
#			followup = true
##			gui.dialogue(content)
#	if !followup:
#		if not world.check_end_game(true):
#			call_deferred("return_control")

func return_control():
	print("return control")
	gui.back()
	selector.enable()
