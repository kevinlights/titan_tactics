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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func cancel_typing():
	typing_cancelled = true
	typing = false
#
#func set_text(text):
#	$text.text = text

func set_text(text):
	cancel_typing()
#	if $background/title.text == "":
#		$background/body.margin_top = 8
#	else:
#		$background/body.margin_top = 18
	$text.text = ""
	call_deferred("resize")
	current_block = text
	typing = true
	typing_cancelled = false
	for i in text:
		typing_timer = yield(get_tree().create_timer(0.05), "timeout")
		if not typing_cancelled:
			$text.text += i
			rng.randomize()
			var my_random_number = rng.randf_range(1.1, 1.4)
#			$textsfx.set_pitch_scale(my_random_number)
#			$textsfx.play()
			if $text.get_visible_line_count() > 3:
				typing_cancelled = true
		else:
			break
	typing = false

func set_content(dialogue_content):
	$more.hide()
#	for item in $branches.get_children():
#		item.hide()
#	$branches.hide()
	content = dialogue_content
	text_blocks = content.messages[index].message.split("|")
#	portrait.hide()
#	if dialogue_content.audio_theme and dialogue_content.audio_theme != "":
#		var music = get_tree().get_root().get_node("World/music")
#		music.get_node(Game.get_theme()).stop()
#		if music.get_node(dialogue_content.audio_theme):
#			music.get_node(dialogue_content.audio_theme).play()
#	if dialogue_content.portrait != PT_Dialogue.PORTRAIT.NONE:
#		var offset = portrait_offset_friendly
#		if "ai" in portrait_map[dialogue_content.portrait] or "revealed" in portrait_map[dialogue_content.portrait]:
#			offset = portrait_offset_enemy
#		portrait.position.x = offset.x
#		portrait.position.y = 144 - dialogue_height + offset.y
#		portrait.play(portrait_map[dialogue_content.portrait])
#		if not has_node("portrait"):
#			add_child(portrait)
#		portrait.show()
#	if dialogue_content.title and dialogue_content.title != "":
#		set_title(dialogue_content.title)
#	else:
#		set_title("")
	set_text(text_blocks[0])
	text_blocks.remove(0)
	print("follow up texts ", text_blocks.size())
	if text_blocks.size() > 0:
		print("show more arrow")
		$more.show()
#	if content.branches.size() > 0:
#		$branches.show()
#		$branches/trigger_1/option_text.text = content.branches[0].text
#		$branches/trigger_1.show()
#		$branches/trigger_1.grab_focus()
#		if content.branches.size() > 1:
#			$branches/trigger_2/option_text.text = content.branches[1].text
#			$branches.margin_bottom = 74
#			$branches/trigger_2.show()
#		if content.branches.size() > 2:
#			$branches/trigger_3/option_text.text = content.branches[2].text
#			$branches/trigger_3.show()
#			$branches.margin_bottom = 96

func _input(event):
	if not visible:
		return
#	if content.branches.size() > 0:
#		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if typing:
			typing_cancelled = true
			typing = false
			$text.text = current_block
		elif text_blocks.size() > 0:
			set_text(text_blocks[0])
			text_blocks.remove(0)
			if text_blocks.size() > 0:
				$more.show()
			else:
				$more.hide()
		else:
			print("dialogue completed")
#			content.complete()
