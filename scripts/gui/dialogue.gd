extends Control

var content
var dialogue_height
var portrait_offset_friendly = Vector2(20, -25)
var portrait_offset_enemy = Vector2(140, -25)
var portrait
var typing = false
var typing_cancelled = false
var text_blocks = []
var current_block = ""
var rng = RandomNumberGenerator.new()

var portrait_map = {
	Dialogue.PORTRAIT.ARCHER: "archer",
	Dialogue.PORTRAIT.SWORDSMAN: "swordsman",
	Dialogue.PORTRAIT.MAGE: "mage",
	Dialogue.PORTRAIT.AI_ARCHER: "ai_mage",
	Dialogue.PORTRAIT.AI_SWORDSMAN: "ai_swordsman",
	Dialogue.PORTRAIT.AI_MAGE: "ai_mage",
	Dialogue.PORTRAIT.HERO_SWORDSMAN: "hero_swordsman",
	Dialogue.PORTRAIT.OLD_MAN: "old_man"
}

func _ready():
	portrait = load("res://scenes/portraits.tscn").instance()
	dialogue_height = 6 + 10 * 3 #$background/body.get_visible_line_count()
	$background.rect_size.y = dialogue_height
	$background.rect_position.y = 144 - dialogue_height
#
func resize():
	dialogue_height = 6 + 10 * 3 # $background/body.get_visible_line_count()
	$background.rect_size.y = dialogue_height
	$background.rect_position.y = 144 - dialogue_height

func set_content(dialogue_content):
	content = dialogue_content
	text_blocks = content.text.split("|")
	if dialogue_content.portrait != Dialogue.PORTRAIT.NONE:
		var offset = portrait_offset_friendly
		if "ai" in portrait_map[dialogue_content.portrait]:
			offset = portrait_offset_enemy
		portrait.position.x = offset.x
		portrait.position.y = 144 - dialogue_height + offset.y
		portrait.play(portrait_map[dialogue_content.portrait])
		add_child(portrait)

	set_text(text_blocks[0])
	text_blocks.remove(0)
	
func set_text(text):
	$background/body.text = ""
	call_deferred("resize")
	current_block = text
	typing = true
	typing_cancelled = false
	for i in text:
		yield(get_tree().create_timer(0.05), "timeout")
		if not typing_cancelled:
			$background/body.text += i			
			rng.randomize()
			var my_random_number = rng.randf_range(5.0, 6.0)
			$textsfx.set_pitch_scale(my_random_number)
			$textsfx.play()
			if $background/body.get_visible_line_count() > 3:
				typing_cancelled = true
		else:
			break
	typing = false

func _input(event):
	if not visible:
		return
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
		if typing:
			typing_cancelled = true
			typing = false
			$background/body.text = current_block
		elif text_blocks.size() > 0:
			set_text(text_blocks[0])
			text_blocks.remove(0)
		else:
			print("dialogue completed")
			content.complete()
