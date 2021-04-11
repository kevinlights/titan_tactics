class_name DialogueAction
extends Resource

signal completed

export(String) var action
export(String) var target
export(String) var music

func complete():
	emit_signal("completed")
