class_name Dialogue
extends Resource

signal completed

export(Array, Resource) var messages = []

func complete():
	emit_signal("completed")
