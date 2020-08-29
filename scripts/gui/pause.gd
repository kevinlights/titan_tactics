extends CenterContainer

signal resume
signal quit

func _ready():	
	$panel/margin/vbox/resume.connect("pressed", self, "emit_signal", ["resume"])
	$panel/margin/vbox/quit.connect("pressed", self, "emit_signal", ["quit"])

func show_dialog():
	$panel/margin/vbox/resume.grab_focus()
	show()
