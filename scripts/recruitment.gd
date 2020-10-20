class_name Recruitment
extends Object

signal response
signal completed

var choice = 0
var options = []
enum PERSONALITY {
	AGGRESSIVE,
	NARCISSIST,
	GREEDY
}

var introductions = {
	PERSONALITY.AGGRESSIVE: [
		"Have at thee!!",
		"I'll... I'll kill you!",
		"The Black Knight always triumphs!"
	],
	PERSONALITY.NARCISSIST: [
		"No... I am unbeatable!",
		"My skill is unmatched!",
		"You cannot comprehend my prowess!"
	],
	PERSONALITY.GREEDY: [
		"I don't get paid enough for this!",
		"If I had a gold bar for every fool I've killed...",
		"I need to ask for a raise!"
	]
}

var persuasion = {
	PERSONALITY.AGGRESSIVE: [
		"Join us or I'll gut you like a sturgeon!",
		"Your life is forfeit, join us or die!",
		"Join us or I'll eat your lunch, pal!"
	],
	PERSONALITY.NARCISSIST: [
		"We could use your skill! Lend us your sword!",
		"Your strength is impressive, join us!",
		"We need people of your caliber"
	],
	PERSONALITY.GREEDY: [
		"So, how about a raise?",
		"I can pay double, if you join.",
		"Stick with me, I will reward you!"
	]
}

var accept = {
	PERSONALITY.AGGRESSIVE: [
		"You've got the right attitude. I'm in!.",
		"Alright, let's split some skulls!",
		"I like your style! I'll join you."
	],
	PERSONALITY.NARCISSIST: [
		"You really don't stand a chance without me.",
		"Just don't make me look bad out there.",
		"Yeah, but don't expect me to do all the work."
	],
	PERSONALITY.GREEDY: [
		"Now that's an offer I won't refuse!",
		"OK, but as long as I'm killing, I'm billing.",
		"Sounds profitable, I'm in!"
	]
}

var deny = {
	PERSONALITY.AGGRESSIVE: [
		"I will cut you to ribbons!",
		"This will not stand. Prepare to die!",
		"Your body will never be found!"
	],
	PERSONALITY.NARCISSIST: [
		"I don't think you fully appreciate what I offer.",
		"Taste of my steel, you insolent mortal!",
		"You are not worthy."
	],
	PERSONALITY.GREEDY: [
		"Did you really think that would work?",
		"Your pretty words won't work on me!",
		"You couldn't afford to pay me enough."
	]
}

var personality
var character
var intro

var portrait_map = {
	TT.TYPE.ARCHER: "ai_archer",
	TT.TYPE.MAGE: "ai_mage",
	TT.TYPE.FIGHTER: "ai_fighter",
	TT.TYPE.BOBA: "ai_boba",
}

func _init(character, personality = null):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if personality == null:
		personality = rng.randi_range(0, 2)
	#it's 3 for some reason
	self.personality = personality
	self.character = character
	var num_intros = introductions[personality].size()
	intro = Dialogue.new()
	var message = DialogueMessage.new()
#	intro.title = character.name
	message.message = introductions[personality][rand_range(0, num_intros)]
	message.title = portrait_map[character.character_class]
	intro.messages.append(message)
	options.append(generate_branch(PERSONALITY.AGGRESSIVE))
	options.append(generate_branch(PERSONALITY.NARCISSIST))
	options.append(generate_branch(PERSONALITY.GREEDY))
	options.shuffle()
#	intro.branches.append(generate_branch(PERSONALITY.AGGRESSIVE))
#	intro.branches.append(generate_branch(PERSONALITY.NARCISSIST))
#	intro.branches.append(generate_branch(PERSONALITY.GREEDY))
#	intro.branches.shuffle()
#	intro.connect("completed", self, "_on_branch")

func complete():
	emit_signal("completed", choice)

func _on_branch(id):
	print("branch ", id)
	choice = id
	if id == self.personality:
		emit_signal("response", generate_response(true))
	else:
		emit_signal("response", generate_response(false))

func generate_branch(personality):
	var branch = {}
	var num_responses = persuasion[personality].size()
	branch.text = persuasion[personality][rand_range(0, num_responses)]
	branch.id = personality
	return branch
	
func generate_response(accepted):
	var response = Dialogue.new()
	var message = DialogueMessage.new()
	var num_options = accept[personality].size()
	if not accepted:
		num_options = deny[personality].size()
		message.message = deny[personality][rand_range(0, num_options)]
		response.id = "denied"
	else:
		message.message = accept[personality][rand_range(0, num_options)]
		response.id = "accepted"
	message.title = portrait_map[character.character_class]
#	response.portrait = portrait_map[character.character_class]
#	response.messages.append(message)
	print("responding ", message.message)
	response.messages = [ message ]
	return response
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
