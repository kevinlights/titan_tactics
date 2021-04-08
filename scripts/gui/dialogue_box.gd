extends Control

signal closed
signal cutscene_start
signal cutscene_end

var event_will_progress = true

# typing flag
var typing: bool = false
# typing speed
var typingSpeed: float = 0.1

onready var selector = get_tree().get_root().get_node("World/select")
onready var world = get_tree().get_root().get_node("World")
var _textNode: Label
var _timer: Timer
var _moreNode: Control
var scriptContent: Array

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
	self.typing = true
	print("[DialogBox] Start printing text...")
	_timer.start()

# ~~~ 
# Actions
# ~~~ 


# > hint <story_marker>
func action_hint(target) -> void:
	var marker = world.find_story_marker(target)
	if marker:
		world.range_overlay.set_hint_tile(marker.translation)
	else:
		world.range_overlay.set_hint_tile(null)

# > select <character>
func action_select(target) -> void:
	var charTarget = world.find_character(target)
	world.get_node("lookat/camera").track(charTarget)
	world.select_by_name(target)

# > win
func action_win() -> void:
	world.game_over = true
	world.emit_signal("win")
	world.call_deferred("_on_win")

func action_despawn(target) -> void:
	var target_character = world.find_character(target)
	if target_character:
		target_character.despawn()
	else:
		print("[DialogBox] Error - can't despawn: ",target)

func action_face(target) -> void:
	var name_direction = target.split(".")
	var target_character = world.find_character(name_direction[0])
	if target_character:
		target_character.face(name_direction[1])
	else:
		print("[!!] invalid target character!")

func action_emote(target) -> void:
	var name_emote = target.split(".")
	var target_character = world.find_character(name_emote[0])
	if target_character:
		target_character.connect("emote_finished",self, "_emote_done", [target_character], CONNECT_ONESHOT)
		target_character.emote(name_emote[1])
	else:
		print("[!!] invalid target character!")
		_emote_done(target_character)


func action_move(target) -> void:
	var target_character = world.find_character(target)
	var marker = world.find_story_marker(target)
	var character = world.get_current()
	var path = PoolVector3Array()
	if target_character:
		path = world.pathfinder.find_path(character.translation, target_character.translation, world.get_blocked_cells())
		path.resize(path.size() - 1)
	elif marker:
		path = world.pathfinder.find_path(character.translation, marker.translation, world.get_blocked_cells())
	#character.connect("path_complete", self, "advance", [], CONNECT_ONESHOT)
	character.connect("path_complete", self, "_move_done", [], CONNECT_ONESHOT)
	character.move(path, true)

func action_focus(target) -> void:
	var marker = world.find_story_marker(target)
	if not marker:
		marker = world.find_character(target)
	world.get_node("lookat/camera").track(marker)

func action_attack(target) -> void:
	var name_direction = target.split(".")
	var target_character = world.find_character(name_direction[0])
	if !target_character:
		print("[DialogBox] cannot find character: ",name_direction[0])
		return
	var target_target = world.find_story_marker(name_direction[1])
	if !target_target:
		print("[DialogBox] cannot find story marker: ",name_direction[1])
		return
	if target_character.character.character_class == TT.TYPE.ARCHER:
		var arrow = load("res://scenes/arrow.tscn").instance()
		world.add_child(arrow)
		world.get_node("lookat/camera").track(arrow)
		arrow.connect("hit", self, "_attack_done", [arrow, target_character], CONNECT_ONESHOT)
		arrow.fire(target_character.translation,target_target.translation)

func action_expect(target) -> void:
	world.expected_target = world.find_story_marker(target)

func action_spawn(target) -> void:
	world.surprise_spawn(target)

# ~~~ 
# Main perform
# ~~~ 

func perform_action(item):
	print("[DialogBox] Perform action ",item.action, " ", item.target)
	
	# what does this do?
	# selector.camera_captured = false

	if item.action == "select":
		action_select(item.target)
		advance()
	elif item.action == "hint":
		action_hint(item.target)
		advance()
	elif item.action == "win":
		action_win()
	elif item.action == "despawn":
		action_despawn(item.target)
		advance()
	elif item.action == "face":
		action_face(item.target)
		advance()
	elif item.action == "emote":
		action_emote(item.target)
	elif item.action == "move":
		action_move(item.target)
	elif item.action == "focus":
		action_focus(item.target)
		advance()
	elif item.action == "attack":
		action_attack(item.target)
	elif item.action == "spawn":
		action_spawn(item.target)
		advance()
	elif item.action == "expect":
		action_expect(item.target)
		advance()
	else:
		print("[DialogBox] unknown action: ",item.action)

# ~~~
# Callbacks
# ~~~


func _attack_done(_arrow, target_character):
	# remove event, solved by CONNECT_ONESHOT
	#if arrow.is_connected("hit", self, "_attack_done"):
	#	arrow.disconnect("hit", self, "_attack_done")
	world.get_node("lookat/camera").track(target_character)
	print("[DialogBox] Attack done - advancing.")
	if event_will_progress:
		advance()
	

func _emote_done(_emote_source):
	# remove event, solved by CONNECT_ONESHOT
	#if emote_source.is_connected("emote_finished", self, "_emote_done"):
	#	emote_source.disconnect("emote_finished", self, "_emote_done")

	event_will_progress = true

	#if _emote_source != null:
		### FOR GOD'S SAKE SOLVE THIS WITH A ANIMATIONCONTROLLER
		#_emote_source.get_node("emotes").show()
		#yield(get_tree().create_timer(1.0),"timeout")
		#_emote_source.get_node("emotes").hide()
		
	print("[DialogBox] Emoting done - advancing.")
	if event_will_progress:
		advance()

func _move_done():
	print("[DialogBox] Move done - advancing.")
	advance()


func showMessageDialog(content):
	selector.disable()
	_moreNode.hide()
	set_textbox_content(content.message)
	print("[DialogBox] Printing message - face? ", content.title)
	if content.title:
		$portrait/portraits.play(content.title.lstrip(" ").rstrip(" "))

	show()
	_moreNode.show()


# ~~~
# old
# ~~~
func out():
	print("[DialogBox] 'out' was called.")
	# attach camera to selector and return control to player
	world.get_node("lookat/camera").track(selector)
	selector.enable()
	world.current_turn = TT.CONTROL.PLAYER
	self.hide()
	emit_signal("closed")
	emit_signal("cutscene_end")


func dismiss():
	hide()
	emit_signal("closed")


# return control (apparently)
func return_control():
	get_parent().back()

func advance():
	print("[DialogBox] Advance!")
	event_will_progress = false	
	if scriptContent.size() <= 0:	
		print("[DialogBox] done.")
		return_control()
		return

	print("[DialogBox] There is still stuff left - let's check")
	var currentMessage = scriptContent.pop_front()
	if "message" in currentMessage:
		print("[DialogBox] Display next message -> ",currentMessage.title," ",currentMessage.message)
		showMessageDialog(currentMessage)
	else:
		print("[DialogBox] Perform action")
		perform_action(currentMessage)

	if "music" in currentMessage and currentMessage.music != null:
		world.play_music(currentMessage.music)
	

func _input(event):
	if not self.visible:
		return
	if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
		if typing:
			self.typingDone()
		else:
			advance()
	if event.is_action("context_cancel") && !event.is_echo() && event.is_pressed():
		#skip = true
		hide()
		advance()

func splitMessageIntoChunks(text) -> Array:
	text = text.replace("\n", " ")
	var words = text.split(" ")
	var chunks = []
	_textNode.text = ""
	var chunk = PoolStringArray()
	for word in words:
		chunk.append(word)
		_textNode.text = chunk.join(" ")
		if _textNode.get_line_count() > 3:
			chunk.resize(chunk.size() - 1)
			chunks.append(chunk.join(" "))
			chunk = PoolStringArray()
			chunk.append(word)
	if chunk.size() > 0:
		chunks.append(chunk.join(" "))
	return chunks
	
func init(dialogue_content):
	print("[DialogBox] Init cutscene")

	hide()
	# split messages
	scriptContent = []
	for content in dialogue_content.messages:
		if "message" in content:
			if content.message != "":
				for chunk in splitMessageIntoChunks(content.message):
					var r = DialogueMessage.new()
					r.title = content.title
					r.message = chunk				
					scriptContent.push_back(r)
		else:
			scriptContent.push_back(content)
	
	_textNode.text = ""

	emit_signal("cutscene_start")
	advance()
