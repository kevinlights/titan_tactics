class_name Dialogue
extends Control

signal completed
signal closed

# event progression flag
var event_will_progress = true
# skip flag
var skip_events = false

# gui flag
var waiting_for_skip_confirm = false

# typing flag
var typing: bool = false
# typing speed
var typingSpeed: float = 0.07

var _textNode: Label
var _timer: Timer
var _moreNode: Control

var message_content

var logger = Logger.new("Dialogue")

# Setting up timer node
func _ready() -> void:
	_textNode = $text
	_moreNode = $more
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.paused = false
	_timer.wait_time = typingSpeed
	_timer.name = 'textTimer'
	var _ret = _timer.connect("timeout", self, "_onTextTimerTick")
	self.add_child(_timer)
	typing = false

# typing is done
func typingDone() -> void:
	_timer.stop()
	typing = false
	$text.set_visible_characters(-1)

# type tick
func _onTextTimerTick() -> void:
	if !visible or !_textNode:
		return
	if _textNode.visible_characters < _textNode.text.length():
		_textNode.visible_characters += 1
	else:
		typing = false

# setting text
func set_textbox_content(text) -> void:
	$text.set_visible_characters(0)
	$text.text = text
	typing = true
	logger.info("Start printing text...")
	_timer.start()

func init(content):
	# if skip_events:
	#     advance()
	#     return
	message_content = content
	# selector.disable()
	_moreNode.hide()
	set_textbox_content(message_content.message.pop_front())
	#logger.info("[DialogBox] logger.infoing message - face? ", content.title)
	if content.title:
		$portrait/portraits.play(content.title.lstrip(" ").rstrip(" "))

	show()
	if message_content.message.size() > 0:
		_moreNode.show()

func out():
	logger.info("'out' was called.")
	# attach camera to selector and return control to player
	# world.get_node("lookat/camera").track(selector)
	# selector.enable()

	# var world = get_tree().get_root().get_node("World")
	# if world.pathfinder != null && world.pathfinder.overlay != null:
	# 	world.pathfinder.overlay.visible = true

	# world.current_turn = TT.CONTROL.PLAYER
	self.hide()

	# world.get_node("gui/skiptip").visible = false
	# emit_signal("closed")
	# emit_signal("cutscene_end")

func _input(event):
	if not self.visible:
		return

	if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
		if typing:
			self.typingDone()
		elif message_content.message.size() > 0:
			set_textbox_content(message_content.message.pop_front())
			if message_content.message.size() > 0:
				_moreNode.show()
			else:
				_moreNode.hide()
		else:
			get_parent().back()
			emit_signal("completed")
