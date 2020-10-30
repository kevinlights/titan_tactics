class_name Dialogue
extends Resource

signal completed

var consumed = false
var id = "dialogue"
export(Array, Resource) var messages = []

func complete():
	consumed = true
	emit_signal("completed", id)
