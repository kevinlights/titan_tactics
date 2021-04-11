extends Node2D

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("focus_entered", self, "show")
# warning-ignore:return_value_discarded
	get_parent().connect("focus_exited", self, "hide")
