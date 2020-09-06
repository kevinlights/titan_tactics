class_name Dialogue
extends Resource

signal completed
signal dialogue_result

enum TRIGGER { 
	DISABLED = 0,
	TEXT,
	ATTACK,
	ADJACENT,
	LEVEL,
	DIALOGUE,
	LEVEL_COMPLETE
}

enum PORTRAIT {
	ARCHER,
	SWORDSMAN,
	MAGE,
	AI_ARCHER,
	AI_SWORDSMAN,
	AI_MAGE,
	HERO,
	ANTAGONIST,
	OLD_MAN,
	CYAN,
	NONE,
	ANTAGONIST_REVEALED
}

enum RESULT { 
	ATTACK = 0,
	RECRUIT,
	NOTHING
}

export(String) var dialogue_id
export(PORTRAIT) var portrait
export(TRIGGER) var trigger
export(String) var trigger_id
export(String) var title
export(String) var text
export(Array, Resource) var branches
export(String) var audio_theme

var consumed = false

func complete():
	consumed = true
	emit_signal("completed", dialogue_id)
#	if result != RESULT.NOTHING:
#		emit_signal("dialogue_result", result)
	
func branch(id):
	emit_signal("completed", id)
