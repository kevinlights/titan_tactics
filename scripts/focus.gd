extends Node2D

func _ready():
	get_parent().connect("focus_entered", self, "show")
	get_parent().connect("focus_exited", self, "hide")
