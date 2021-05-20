class_name Story
extends Resource

signal completed

var consumed = false
var id = "dialogue"
export(Array, Resource) var messages = []

func complete():
	consumed = true
	emit_signal("completed", id)

func _init(json_data = null):
	if json_data:
		from_json(json_data)

func from_json(json_data):
	messages = []
	for message in json_data:
		if "avatar" in message and "text" in message:
			var msg = StoryMessage.new()
			msg.message = PoolStringArray(message.text).join("\n")
			msg.title = message.avatar
			messages.append(msg)
		if "type" in message and "target" in message:
			var action = StoryAction.new()
			action.action = message.type
			action.target = message.target
			messages.append(action)
