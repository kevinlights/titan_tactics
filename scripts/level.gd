extends Node

export(Resource) var start_dialogue
export(Resource) var end_dialogue
export(String) var add_character
export(String) var remove_character
export(String) var map_node = "SINGLE"
onready var world = get_tree().get_root().get_node("World")
onready var gui = get_tree().get_root().get_node("World/gui")
onready var selector = get_tree().get_root().get_node("World/select")

func _ready():
	gui.get_node("teamconfirm").connect("start_level", self, "_on_start_level")
	world.connect("win", self, "_on_end_level")
	world.connect("all_enemies_eliminated", self, "_on_end_level")
	world.connect("auto_deployed", self, "_on_start_level")
#	for content in dialogue:
	if start_dialogue:
		start_dialogue.connect("completed", self, "_on_dialogue_complete")
		start_dialogue.connect("completed", world, "_on_dialogue_complete")		
	if end_dialogue:
		end_dialogue.connect("completed", self, "_on_dialogue_complete")
		end_dialogue.connect("completed", world, "_on_dialogue_complete")
	var triggers = get_tree().get_nodes_in_group ("dialogue_triggers")
	print("level dialogue triggers: ", triggers.size())
	for trigger in triggers:
		trigger.connect("trigger", self, "_on_dialogue_complete")
	if add_character and add_character != "":
		var additional_character = load("res://resources/" + add_character + ".tres")
		additional_character.control = TT.CONTROL.PLAYER
		Game.team.append(additional_character)
	if remove_character and remove_character != "":
		var found = null
		for character in Game.team:
			if character.name.nocasecmp_to(remove_character) == 0:
				found = character
				break
		if found:
			Game.team.erase(found)

func _on_start_level():
	if start_dialogue:
		gui.dialogue(start_dialogue)
#	if dialogue.size() > 0 and dialogue[0].trigger == PT_Dialogue.TRIGGER.LEVEL:
#		gui.dialogue(dialogue[0])

func _on_end_level():
	SaveLoadSystem.save_game()
	print("dialog end level check")
	if end_dialogue:
		gui.dialogue(end_dialogue)
#	if dialogue.size() > 0:
#		for content in dialogue:
#			if not content.consumed and content.trigger == PT_Dialogue.TRIGGER.LEVEL_COMPLETE:
#				gui.dialogue(content)
#				break

func _on_dialogue_complete(id):
	print("completed ", id)
	var followup = false
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
