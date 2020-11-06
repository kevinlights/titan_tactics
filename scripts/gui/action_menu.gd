extends Control

signal attack
signal recruit
signal guard
signal end
signal heal

var start
# var native_x = -50
# var ttl = 60
var done = true
var menu_type = "attack"

#enum MENU {
#	ATTACK,
#	GUARD,
#	HEAL
#}

var signal_map = {
	"attack": [ "attack", "recruit" ],
	"guard": [ "guard", "end" ],
	"heal": [ "heal", "end" ],
	"end": [ "end" ]
}

var label_map = {
	"attack": [ "Attack", "Speak" ],
	"guard": [ "Guard", "End" ],
	"heal": [ "Heal", "End" ],
	"end": [ "End" ]
}


func _ready():
	$panel/action_1.grab_focus()
	$panel/action_1.connect("pressed", self, "_on_action_1")
	$panel/action_2.connect("pressed", self, "_on_action_2")

func _on_action_1():
	get_parent().back()
	emit_signal(signal_map[menu_type][0])

func _on_action_2():
	get_parent().back()
	emit_signal(signal_map[menu_type][1])
	
func init(menu_type = "attack"):
	self.menu_type = menu_type
	$panel/action_1.text = label_map[menu_type][0]
	if label_map[menu_type].size() > 1:
		$panel/action_2.text = label_map[menu_type][1]
		$panel/action_2.show()
	else:
		$panel/action_2.hide()
	start = OS.get_ticks_msec()
	done = false
#	margin_left = 0
	$panel/action_1.grab_focus()
	show()

func out():
	hide()
#
#func _process(delta):
#	if !visible or done:
#		return
#	var now = OS.get_ticks_msec()
#	if now - start < ttl:
#		margin_left = lerp(0, native_x, float(now - start) / float(ttl))
#	else:
#		done = true
#		margin_left = native_x

#func _input(event):
#	if !visible:
#		return
#	if event.is_action("ui_cancel") && !event.is_echo() && event.is_pressed():
#		hide()
#		get_parent().active = false
