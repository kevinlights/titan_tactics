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

func _process(delta):
	if !visible:
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

func _input(event):
	if not visible:
		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if typing:
			typing_cancelled = true
			typing = false
			$text.set_visible_characters(-1)
		elif text_blocks.size() > 0:
			set_text(text_blocks[0])
			text_blocks.remove(0)
			if text_blocks.size() > 0:
				$more.show()
			else:
				$more.hide()
		else:
			print("dialogue completed")
			if index < content.messages.size() -1:
				set_content(content, index + 1)
#			content.complete()
