class_name StatusEffect
extends Resource

enum EFFECT {
	STUN,
	POISON,
	NONE
}

export(EFFECT) var effect = EFFECT.NONE
export(int) var turns = 0
export(int) var damage = 0
export(String) var name

var turns_left = 0

func stun(turns):
	self.turns = turns
	turns_left = turns
	effect = EFFECT.STUN

func poison(turns, damage):
	self.turns = turns
	self.damage = damage
	effect = EFFECT.POISON
