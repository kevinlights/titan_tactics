extends Control

signal resume
signal quit
signal closed

func _ready():
	$menu/resume.connect("pressed", self, "emit_signal", ["resume"])
	$menu/quit.connect("pressed", self, "emit_signal", ["quit"])

func init(_arg):
	$menu/resume.grab_focus()
	show()

func out():
	hide()
	emit_signal("closed")
