extends Node2D

export(Array, Resource) var dialogue

onready var gui = get_tree().get_root().get_node("World/gui")
onready var selector = get_tree().get_root().get_node("World/select")
func _ready():
	gui.get_node("teamconfirm").connect("start_level", self, "_on_start_level")
	for content in dialogue:
		content.connect("completed", self, "_on_dialogue_complete")

func _on_start_level():
	if dialogue.size() > 0 and dialogue[0].trigger == Dialogue.TRIGGER.LEVEL:
		gui.dialogue(dialogue[0])
	
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
		call_deferred("return_control")

func return_control():
	print("return control")
	gui.back()
	selector.enable()
