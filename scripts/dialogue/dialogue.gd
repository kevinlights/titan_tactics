class_name Dialogue
extends Resource

signal completed

var id = "dialogue"
export(Array, Resource) var messages = []

func complete():
	emit_signal("completed", id)
