extends CenterContainer

signal resume
signal quit

func _ready():	
	$menu/resume.connect("pressed", self, "emit_signal", ["resume"])
	$menu/quit.connect("pressed", self, "emit_signal", ["quit"])

func show_dialog():
	$menu/resume.grab_focus()
	show()
