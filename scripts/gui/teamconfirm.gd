extends Control

# linter doesn't "see" these being emitted, because we're chaining them
# warning-ignore:unused_signal
signal check_map
# warning-ignore:unused_signal
signal edit_team
# warning-ignore:unused_signal
signal start_level
signal closed

func _ready():
	# warning-ignore:return_value_discarded
	$panel/start_level.connect("pressed", self, "emit_signal", ["start_level"])
	# warning-ignore:return_value_discarded
	$panel/edit_team.connect("pressed", self, "emit_signal", ["edit_team"])
	# warning-ignore:return_value_discarded
	$panel/check_map.connect("pressed", self, "emit_signal", ["check_map"])

func init(_arg):
	$panel/start_level.grab_focus()
	show()

func out():
	hide()
	emit_signal("closed")

