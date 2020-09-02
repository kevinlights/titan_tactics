extends Control

signal check_map
signal edit_team
signal start_level

func _ready():	
	$panel/start_level.connect("pressed", self, "emit_signal", ["start_level"])
	$panel/edit_team.connect("pressed", self, "emit_signal", ["edit_team"])
	$panel/check_map.connect("pressed", self, "emit_signal", ["check_map"])

func show_dialog():
	$panel/start_level.grab_focus()
	show()
