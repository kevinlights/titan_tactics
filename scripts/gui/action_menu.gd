extends Control

# warning-ignore:unused_signal
signal attack
# warning-ignore:unused_signal
signal recruit
# warning-ignore:unused_signal
signal guard
# warning-ignore:unused_signal
signal end
# warning-ignore:unused_signal
signal heal

signal action
signal closed

var start
# var native_x = -50
# var ttl = 60
var done = true
var menu_type = TT.TYPE.FIGHTER

var disabled = []

var label_map = {
#	"attack": [ "Attack", "Speak" ],	
#	"guard": [ "Guard", "End" ],
#	"heal": [ "Healing Light", "End" ],
#	"end": [ "End" ],
	TT.TYPE.MAGE: [ "Lightning Bolt", "Thunder Storm", "Healing Light", "End" ],
	TT.TYPE.ARCHER: [ "Sharp Shot", "Flame Shower", "Guard", "End" ],
	TT.TYPE.FIGHTER: [ "Heavy Blow", "Sweeping Blow", "Guard", "End" ]
}

var tooltips = {
	"Heavy Blow": "A mighty swing of the sword that targets one",
	"Sweeping Blow": "Slash up to three enemies in front of you with this devastating attack",
	"Sharp Shot": "Line up an arrow and let it loose with frightening accuracy",
	"Flame Shower": "Shoots a bundle of flaming arrows that can damage up to 5 enemies at once. May cause burn",
	"Lightning Bolt": "High precision electric projectile that targets one",
	"Thunder Storm": "Summons a mighty storm that can damage up to 4 enemies at once. May stun enemies",
	"Healing Light": "Restores a little bit of health to yourself or an ally",
	"Guard": "Adopts a defensive stance in order to reduce incoming damage",
	"End": "Ends turn for this character"
}

func _ready():
	pass

func _on_action(item):
	if item in disabled:
		print("[ACTION MENU] pressed disabled item: ", item)
		get_parent().get_node("sfx/denied").play()
		return
	emit_signal("action", item)
	print("[ACTION MENU] ", item)
	get_parent().back()

func _on_focus(item):
	$panel/tip_box/tooltip.text = tooltips[item]

func init(new_menu_type = "attack"):
	menu_type = new_menu_type
	for child in $panel/box.get_children():
		child.queue_free()

	disabled = []
	var action_item_scene = load("res://scenes/gui/action_menu_item.tscn")
	for label in label_map[menu_type]:
		var action_item = action_item_scene.instance()
		action_item.text = label
		action_item.name = label
		$panel/box.add_child(action_item)

	yield(get_tree().create_timer(0.1), "timeout")
	var buttons = $panel/box.get_children()
	for i in range(0, buttons.size()):
		if i > 0:
			buttons[i - 1].focus_next = "../" + buttons[i].name
			buttons[i - 1].focus_neighbour_bottom = "../" + buttons[i].name
			buttons[i].focus_previous = "../" + buttons[i - 1].name
			buttons[i].focus_neighbour_top = "../" + buttons[i - 1].name
		if buttons[i].text != "End" and get_parent().get_parent().get_current().character.turn_limits.actions < 1:
#			buttons[i].disabled = true
			buttons[i].set("custom_colors/font_color", "#8f8f8f")
			buttons[i].set("custom_colors/font_color_hover", "#8f8f8f")
			buttons[i].set("custom_colors/font_color_pressed", "#8f8f8f")
			disabled.append(buttons[i].text)
			print("Disable button ", buttons[i].text)
		buttons[i].rect_position.x = 6
		buttons[i].rect_position.y = i * 16
		buttons[i].connect("pressed", self, "_on_action", [ buttons[i].text ] )
		buttons[i].connect("focus_entered", self, "_on_focus", [ buttons[i].text ] )
	$panel/box.rect_size.y = buttons.size() * 16 + 4
	$panel/tip_box.rect_position.y = $panel/box.rect_position.y + buttons.size() * 16 + 40
	show()
	buttons[0].call_deferred("grab_focus")

func out():
	emit_signal("closed")
	hide()
