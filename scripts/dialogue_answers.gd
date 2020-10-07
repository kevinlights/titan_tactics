extends Control

#signal answered

var recruitment
var selected = 0
var options = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_options(recruitment):
	options = recruitment.options
	self.recruitment = recruitment
	var nodes = $answers.get_children()
	var index = 0
	for child in nodes:
		child.text = options[index].text
		index += 1
#		options.remove(0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if not visible:
		return
	print(options)
	if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
#		emit_signal("answered", options[selected])
		recruitment._on_branch(options[selected].id)
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		selected -= 1
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		selected += 1
	selected = clamp(selected, 0, 2)
	$select.position.y = -100 + selected * 40
		
