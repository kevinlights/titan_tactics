extends Control

signal closed
signal cutscene_start
signal cutscene_end

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
	if skip_events:
		_emote_done(null)
		return
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
	var instant = false
	if skip_events == true:
		instant = true
	character.move(path, true, instant)

func action_focus(target) -> void:
	var marker = world.find_story_marker(target)
	if not marker:
		marker = world.find_character(target)
	world.get_node("lookat/camera").track(marker)

func action_attack(target) -> void:
	if skip_events:
		_attack_done(null,null)
		return
	
	var name_direction = target.split(".")
	var target_character = world.find_character(name_direction[0])
	if !target_character:
		print("[DialogBox] cannot find character: ",name_direction[0])
		return
	var target_target = world.find_story_marker(name_direction[1])
	if !target_target:
		print("[DialogBox] cannot find story marker: ",name_direction[1], " trying for direction")
		# would have left this as left/right/etc but >face already uses west/east/etc
		if name_direction[1] in [ "west", "east", "north", "south" ]:
			var nwse = {
				"west": "left",
				"east": "right",
				"north": "up",
				"south": "down"
			}
			target_character.avatar.play("attack-" +  target_character.directions[Game.camera_orientation][nwse[name_direction[1]]])
			yield(get_tree().create_timer(1.0),"timeout")
			advance()
			return
		else:
			print("[DialogBox] ", name_direction[1], " does not match east/west/north/south")
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
	#print("[DialogBox] Perform action ",item.action, " ", item.target," ")
	
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
	world.get_node("lookat/camera").track(target_character)
	print("[DialogBox] Attack done - advancing.")
	if event_will_progress or skip_events:
		advance()
	

func _emote_done(_emote_source):
	if event_will_progress or skip_events:
		advance()

func _move_done():
	print("[DialogBox] Move done - advancing.")
	advance()


func showMessageDialog(content):
	if skip_events:
		advance()
		return
	
	selector.disable()
	_moreNode.hide()
	set_textbox_content(content.message)
	#print("[DialogBox] Printing message - face? ", content.title)
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

	var world = get_tree().get_root().get_node("World")
	if world.pathfinder != null && world.pathfinder.overlay != null:
		world.pathfinder.overlay.visible = true

	world.current_turn = TT.CONTROL.PLAYER
	self.hide()
	
	world.get_node("gui/skiptip").visible = false
	emit_signal("closed")
	emit_signal("cutscene_end")


func dismiss():
	hide()
	emit_signal("closed")


# return control (apparently)
func return_control():
	get_parent().back()

func advance():
	world.range_overlay.hide()
	#print("[DialogBox] Advance!")
	event_will_progress = false	
	if scriptContent.size() <= 0:	
		#print("[DialogBox] done.")
		return_control()
		return

	#print("[DialogBox] There is still stuff left - let's check")
	var currentMessage = scriptContent.pop_front()

	if "music" in currentMessage and currentMessage.music != null and currentMessage.music != '':
		#print("music in message - playing: ",currentMessage.music)
		world.play_music(currentMessage.music)

	if "message" in currentMessage:
		#print("[DialogBox] Display next message -> ",currentMessage.title," ",currentMessage.message)
		showMessageDialog(currentMessage)
	else:
		#print("[DialogBox] Want to perform action...")
		perform_action(currentMessage)

	

func _input(event):
	if waiting_for_skip_confirm:
		return
	if not self.visible:
		return
	if skip_events:
		return
		
	if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
		if typing:
			self.typingDone()
		else:
			advance()
			
	if event.is_action("context_menu") && !event.is_echo() && event.is_pressed():
		#skip_events = true
		#advance()
		#get_parent().start("skipconfirm")
		hide()
		get_parent().get_node("skipconfirm").show()
		get_parent().get_node("skipconfirm").connect("confirm_skip", self, "skip_confirmed")
		get_parent().get_node("skipconfirm").connect("cancel", self, "skip_cancelled")
		world.get_node("gui/skiptip").visible = false
		waiting_for_skip_confirm = true

func skip_confirmed():
	skip_events = true
	waiting_for_skip_confirm = false
	hide()
	advance()

func skip_cancelled():
	waiting_for_skip_confirm = false
	skip_events = false
	world.get_node("gui/skiptip").visible = true
	show()

func splitMessageIntoChunks(text) -> Array:
#	text = text.replace("\n", " ")
	return text.split("\n")
#	var words = text.split(" ")
#	var chunks = []
#	_textNode.text = ""
#	var chunk = PoolStringArray()
#	for word in words:
#		chunk.append(word)
#		_textNode.text = chunk.join(" ")
#		if _textNode.get_line_count() > 3:
#			chunk.resize(chunk.size() - 1)
#			chunks.append(chunk.join(" "))
#			chunk = PoolStringArray()
#			chunk.append(word)
#	if chunk.size() > 0:
#		chunks.append(chunk.join(" "))
#	return chunks
	
func init(dialogue_content):
	print("[DialogBox] Init cutscene")
	skip_events = false
	
	hide()
	world = get_tree().get_root().get_node("World")
	if world.pathfinder != null && world.pathfinder.overlay != null:
		world.pathfinder.overlay.visible = false
	world.get_node("gui/skiptip").visible = true
	
	# split messages
	scriptContent = []
	var putMusicAlready: bool
	var storeMusic = ""
	for content in dialogue_content.messages:
		putMusicAlready = false
		if "message" in content:
			if content.message != "":
				for chunk in splitMessageIntoChunks(content.message):
					var r = StoryMessage.new()
					r.title = content.title
					r.message = chunk				
					if not putMusicAlready and "music" in content and content.music != "":
						r.music = content.music
						putMusicAlready = true
					if storeMusic != "" and not putMusicAlready and "music" in content and content.music == "":
						r.music = storeMusic
						storeMusic = ""
						putMusicAlready = true
					
					scriptContent.push_back(r)
			elif "music" in content and content.music != "":
				storeMusic = content.music
		else:
			if storeMusic != "" and not putMusicAlready:
				content.music = storeMusic
				storeMusic = ""
				putMusicAlready = true
			scriptContent.push_back(content)
	
	_textNode.text = ""

	emit_signal("cutscene_start")
	advance()
