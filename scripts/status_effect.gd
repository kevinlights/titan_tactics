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

func stun(effect_turns):
	turns = effect_turns
	turns_left = turns
	effect = EFFECT.STUN

func poison(effect_turns, effect_damage):
	self.turns = effect_turns
	self.damage = effect_damage
	effect = EFFECT.POISON

func polymorph(effect_turns):
	self.turns = effect_turns
	effect = EFFECT.POLYMORPH

func tag():
	var effect_tag
	match(effect):
		EFFECT.POISON:
			effect_tag = "poison"
		EFFECT.STUN:
			effect_tag = "stun"
#		EFFECT.POLYMORPH:
#			effect_tag = "polymorph"
	return effect_tag

func copy(other):
	self.turns = other.turns
	self.damage = other.damage
	self.effect = other.effect
	self.name = other.name
