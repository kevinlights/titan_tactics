extends Control

var content
var dialogue_height
var portrait_offset_friendly = Vector2(18, -25)
var portrait_offset_enemy = Vector2(142, -25)
var portrait
var typing = false
var typing_cancelled = false
var typing_timer
var text_blocks = []
var current_block = ""
var rng = RandomNumberGenerator.new()
var index = 0
var characters_visible = -1
var typing_delay = 50
var last_typed = 0
onready var selector = get_tree().get_root().get_node("World/select")
onready var world = get_tree().get_root().get_node("World")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func cancel_typing():
	typing_cancelled = true
	typing = false
#
#func set_text(text):
#	$text.text = text
func get_chunks(text):
	text = text.replace("\n", " ")
	var words = text.split(" ")
	var chunks = []
	$text.text = ""
	var chunk = PoolStringArray()
	for word in words:
		chunk.append(word)
		$text.text = chunk.join(" ")
		if $text.get_line_count() > 3:
			chunk.resize(chunk.size() - 1)
			chunks.append(chunk.join(" "))
			chunk = PoolStringArray()
			chunk.append(word)
	if chunk.size() > 0:
		chunks.append(chunk.join(" "))
	return chunks
	
func set_text(text):
	current_block = text
	characters_visible = 0
	$text.text = ""
	call_deferred("resize")
	typing = true
	typing_cancelled = false
	$text.set_visible_characters(0)
	$text.text = text
	print(text)

func perform_action(item):
	print(item.action, " ", item.target)
	var target = world.find_character(item.target)
	selector.camera_captured = false
	if item.action == "select":
		world.get_node("lookat/camera").track(target)
		world.select_by_name(item.target)
	if item.action == "move":
		var target_character = world.find_character(item.target)
		var marker = world.find_story_marker(item.target)
		var character = world.get_current()
		var path = PoolVector3Array()
		if target_character:
			path = world.pathfinder.find_path(character.translation, target_character.translation, world.get_blocked_cells())
			path.resize(path.size() - 1)
		elif marker:
			path = world.pathfinder.find_path(character.translation, marker.translation, world.get_blocked_cells())
		character.connect("path_complete", self, "advance", [], CONNECT_ONESHOT)
		character.move(path)
	if item.action == "focus":
		var marker = world.find_story_marker(item.target)
		world.get_node("lookat/camera").track(marker)
	if item.action == "spawn":
		world.surprise_spawn(item.target)
	index += 1

func _process(delta):
	if !visible or !$text:
		return
	var now = OS.get_ticks_msec()
	if now - last_typed > typing_delay:
		last_typed = now
		if typing_cancelled:
			$text.set_visible_characters(-1)
		else:
			if characters_visible < current_block.length():
				$text.set_visible_characters(characters_visible)
				characters_visible += 1
			else:
				typing = false

func set_content(dialogue_content, set_index = 0):
	selector.disable()
	index = set_index
	$more.hide()
	content = dialogue_content
	text_blocks = get_chunks(content.messages[set_index].message)
	print(content.messages[set_index].title)
	if content.messages[set_index].title != "":
		$portrait/portraits.play(content.messages[set_index].title.lstrip(" ").rstrip(" "))

	set_text(text_blocks[0])
	text_blocks.remove(0)
	print("follow up texts ", text_blocks.size())
	if text_blocks.size() > 0:
		print("show more arrow")
		$more.show()
	#if content.music:
		#world.play_music(content.music)

func advance():
	if text_blocks.size() > 0:
		set_text(text_blocks[0])
		text_blocks.remove(0)
		if text_blocks.size() > 0:
			$more.show()
		else:
			$more.hide()
	else:
		print("dialogue completed")
		if index < content.messages.size() -1:
			if "message" in content.messages[index + 1]:
				set_content(content, index + 1)
			else:
				perform_action(content.messages[index + 1])
#					print(content.messages[index + 1].action, content.messages[index + 1].target)
#					index += 1
		else:
			print("emit complete")
			content.complete()
			# attach camera to selector and return control to player
			world.get_node("lookat/camera").track(selector)
			selector.enable()
			world.current_turn = TT.CONTROL.PLAYER
			get_parent().modal = false
			hide()

func dismiss():
	content.complete()
	get_parent().modal = false
	hide()
	world.check_end_game(true)

func _input(event):
	if not visible:
		return
	if not content:
		return
	if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
		if typing:
			typing_cancelled = true
			typing = false
			$text.set_visible_characters(-1)
		else:
			advance()
	if event.is_action("context_cancel") && !event.is_echo() && event.is_pressed():
		dismiss()
#		elif text_blocks.size() > 0:
#			set_text(text_blocks[0])
#			text_blocks.remove(0)
#			if text_blocks.size() > 0:
#				$more.show()
#			else:
#				$more.hide()
#		else:
#			print("dialogue completed")
#			if index < content.messages.size() -1:
#				if "message" in content.messages[index + 1]:
#					set_content(content, index + 1)
#				else:
#					perform_action(content.messages[index + 1])
##					print(content.messages[index + 1].action, content.messages[index + 1].target)
##					index += 1
#			else:
#				print("emit complete")
#				content.complete()
#				hide()
