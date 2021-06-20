extends Control

# warning-ignore:unused_signal
signal resume
# warning-ignore:unused_signal
signal quit
signal closed

func _ready():
# warning-ignore:return_value_discarded
	$menu/resume.connect("pressed", self, "emit_signal", ["resume"])
# warning-ignore:return_value_discarded
	$menu/quit.connect("pressed", self, "emit_signal", ["quit"])

func init(_arg):
	$menu/resume.grab_focus()
	show()

func out():
	hide()
	emit_signal("closed")
