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
		TT.TYPE.MAGE: [ "Lightning Bolt", "Thunder Storm", "Healing Light", "End" ],
		TT.TYPE.ARCHER: [ "Sharp Shot", "Flame Shower", "Guard", "End" ],
		TT.TYPE.FIGHTER: [ "Heavy Blow", "Sweeping Blow", "Guard", "End" ]
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
	$panel/tip_box/tooltip.text = tr("TOOLTIP " + item) #tooltips[item]

func init(new_menu_type = "attack"):
	menu_type = new_menu_type
	for child in $panel/box.get_children():
		child.queue_free()

	disabled = []
	var action_item_scene = load("res://scenes/gui/action_menu_item.tscn")
	for label in label_map[menu_type]:
		var action_item = action_item_scene.instance()
		action_item.text = tr(label)
		action_item.action_name = label
		action_item.name = label
		$panel/box.add_child(action_item)

	yield(get_tree().create_timer(0.1), "timeout")
	var have_focus = false
	var buttons = $panel/box.get_children()
	buttons[0].focus_previous = "../" + buttons[buttons.size() - 1].action_name
	buttons[0].focus_neighbour_top = "../" + buttons[buttons.size() - 1].action_name
	buttons[buttons.size() - 1].focus_next = "../" + buttons[0].action_name
	buttons[buttons.size() - 1].focus_neighbour_bottom = "../" + buttons[0].action_name
	for i in range(0, buttons.size()):
		if i > 0:
			buttons[i - 1].focus_next = "../" + buttons[i].name
			buttons[i - 1].focus_neighbour_bottom = "../" + buttons[i].name
			buttons[i].focus_previous = "../" + buttons[i - 1].name
			buttons[i].focus_neighbour_top = "../" + buttons[i - 1].name
		if buttons[i].text != tr("End") and get_parent().get_parent().get_current().character.turn_limits.actions < 1:
#			buttons[i].disabled = true
			buttons[i].set("custom_colors/font_color", "#8f8f8f")
			buttons[i].set("custom_colors/font_color_hover", "#8f8f8f")
			buttons[i].set("custom_colors/font_color_pressed", "#8f8f8f")
			disabled.append(buttons[i].text)
			print("Disable button ", buttons[i].text)
		buttons[i].rect_position.x = 6
		buttons[i].rect_position.y = i * 16
		buttons[i].connect("pressed", self, "_on_action", [ buttons[i].action_name ] )
		buttons[i].connect("focus_entered", self, "_on_focus", [ buttons[i].action_name ] )
		if !(buttons[i].text in disabled) and !have_focus:
			buttons[i].call_deferred("grab_focus")
			have_focus = true
	$panel/box.rect_size.y = buttons.size() * 16 + 4
	$panel/tip_box.rect_position.y = $panel/box.rect_position.y + buttons.size() * 16 + 40
	show()
#	buttons[0].call_deferred("grab_focus")

func out():
	emit_signal("closed")
	hide()
