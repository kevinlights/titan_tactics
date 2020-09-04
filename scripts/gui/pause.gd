extends CenterContainer

signal resume
signal quit

func _ready():	
	$panel/resume.connect("pressed", self, "emit_signal", ["resume"])
	$panel/quit.connect("pressed", self, "emit_signal", ["quit"])

func show_dialog():
	$panel/resume.grab_focus()
	show()
