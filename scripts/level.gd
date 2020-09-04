extends Node2D

export(Array, Resource) var dialogue

onready var world = get_tree().get_root().get_node("World")
onready var gui = get_tree().get_root().get_node("World/gui")
onready var selector = get_tree().get_root().get_node("World/select")

func _ready():
	gui.get_node("teamconfirm").connect("start_level", self, "_on_start_level")
	world.connect("win", self, "_on_end_level")
	for content in dialogue:
		content.connect("completed", self, "_on_dialogue_complete")

func _on_start_level():
	if dialogue.size() > 0 and dialogue[0].trigger == Dialogue.TRIGGER.LEVEL:
		gui.dialogue(dialogue[0])

func _on_end_level():
	print("dialog end level check")
	if dialogue.size() > 0:
		for content in dialogue:
			if not content.consumed and content.trigger == Dialogue.TRIGGER.LEVEL_COMPLETE:
				gui.dialogue(content)
				break

func _on_dialogue_complete(id):
	print("completed ", id)
	var followup = false
	for content in dialogue:
		if content.trigger == Dialogue.TRIGGER.DIALOGUE and content.trigger_id == id:
			print("dialogue trigger content")
			gui.call_deferred("dialogue", content)
			followup = true
#			gui.dialogue(content)
	if !followup:
		if not world.check_end_game(true):
			call_deferred("return_control")

func return_control():
	print("return control")
	gui.back()
	selector.enable()
