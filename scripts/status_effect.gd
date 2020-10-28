class_name StatusEffect
extends Resource

enum EFFECT {
	STUN,
	POISON,
	POLYMORPH,
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

func polymorph(turns):
	self.turns = turns
	effect = EFFECT.POLYMORPH

func copy(other):
	self.turns = other.turns
	self.damage = other.damage
	self.effect = other.effect
	self.name = other.name
