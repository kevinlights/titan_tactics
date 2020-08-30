class_name Dialogue
extends Resource

signal completed

enum TRIGGER { 
	DISABLED = 0,
	TEXT,
	ATTACK,
	ADJACENT,
	LEVEL
}

enum RESULT { 
	ATTACK = 0,
	RECRUIT,
	NOTHING
}

export(TRIGGER) var trigger
export(String) var trigger_text
export(String) var text
export(Array, Resource) var branches
export(RESULT) var result

func complete():
	emit_signal("completed", result)
	
func branch(text):
	emit_signal("branch", text)
