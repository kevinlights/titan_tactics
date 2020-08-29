extends CenterContainer

signal check_map
signal edit_team
signal start_level

func _ready():	
	$panel/margin/vbox/start_level.connect("pressed", self, "emit_signal", ["start_level"])
	$panel/margin/vbox/edit_team.connect("pressed", self, "emit_signal", ["edit_team"])
	$panel/margin/vbox/check_map.connect("pressed", self, "emit_signal", ["check_map"])

func show_dialog():
	$panel/margin/vbox/start_level.grab_focus()
	show()
