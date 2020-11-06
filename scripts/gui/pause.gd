extends Control

signal resume
signal quit

func _ready():
	$menu/resume.connect("pressed", self, "emit_signal", ["resume"])
	$menu/quit.connect("pressed", self, "emit_signal", ["quit"])

func init(_arg):
	$menu/resume.grab_focus()
	show()

func out():
	hide()
