class_name Story
extends Resource

signal completed
signal start
signal end

signal attack(target)
signal despawn(target)
signal dialogue(avatar, message)
signal emote(target)
signal expect(target)
signal face(target)
signal focus(target)
signal hint(target)
signal move(target)
signal music(target)
signal select(target)
signal spawn(target)
signal win

var consumed = false
var id = "dialogue"
export(Array, Resource) var messages = []

var logger = Logger.new("Story")

func complete():
	consumed = true
	emit_signal("completed", id)
	emit_signal("end")

func _init(json_data = null):
	if json_data:
		from_json(json_data)

func from_json(json_data):
	messages = []
	for message in json_data:
		if "avatar" in message and "text" in message:
			var msg = StoryMessage.new()
			msg.message = message.text # PoolStringArray(message.text).join("\n")
			msg.title = message.avatar
			messages.append(msg)
		if "type" in message and "target" in message:
			var action = StoryAction.new()
			action.action = message.type
			action.target = message.target
			messages.append(action)


func play():
	emit_signal("start")
	advance()

func skip():
	complete()

# we need to rely on the recipient of our action signals to call this when their action is completed.
func advance():
	logger.info("advance")
	if messages.size() > 0:
		var current = messages.pop_front()
		if "message" in current:
			emit_signal("dialogue", current)
		if "action" in current:
			# this is cool and all, but it causes the signal declarations to throw warnings (never emitted)
			logger.info(current.action, current.target)
			emit_signal(current.action, current.target)
	else:
		# no more message items
		logger.info("advance stopped - story over")
		complete()
