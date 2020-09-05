class_name Recruitment
extends Object

signal response

enum PERSONALITY {
	AGGRESSIVE,
	NARCISSIST,
	GREEDY
}

var introductions = {
	PERSONALITY.AGGRESSIVE: [
		"You won't take me alive!",
		"I... I'll kill you!",
		"Hold still, I'll finish this real quick!"
	],
	PERSONALITY.NARCISSIST: [
		"No... I am unbeatable!",
		"My skill is unmatched!",
		"You cannot comprehend my prowess!"
	],
	PERSONALITY.GREEDY: [
		"I don't get paid enough for this!",
		"If I got a gold bar for every fool I've killed...",
		"I need to ask for a raise!"
	]
}

var persuasion = {
	PERSONALITY.AGGRESSIVE: [
		"Either join us or I will gut you like a sturgeon!",
		"Your life is forfeit, join us or die!",
		"You will not live to tell this tale, unless..."
	],
	PERSONALITY.NARCISSIST: [
		"We could use your skill! Lend us your sword!",
		"Your strength is impressive, join us!",
		"We need people of your caliber"
	],
	PERSONALITY.GREEDY: [
		"So, how about a raise?",
		"I can pay double what you're getting!",
		"Stick with me, the rewards will be many!"
	]
}

var accept = {
	PERSONALITY.AGGRESSIVE: [
		"I didn't feel like killing anyone today anyway.",
		"My sword is yours!",
		"Don't kill me! I will join your party."
	],
	PERSONALITY.NARCISSIST: [
		"Let's raise your average strength a bit, shall we?",
		"Thank you for noticing! I will be happy to lend a hand.",
		"Well if you put it like that..."
	],
	PERSONALITY.GREEDY: [
		"Now that's an offer I won't refuse!",
		"Onwards, to treasure!",
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
		"I don't think you fully appreciate what I have to offer.",
		"This technique is called 'stabby stabby', look!",
		"You are not worthy."
	],
	PERSONALITY.GREEDY: [
		"Did you really think that would work?",
		"Your pretty words won't work on me!",
		"You can't intimidate me!"
	]
}

var personality
var character
var intro

var portrait_map = {
	Game.TYPE.ARCHER: Dialogue.PORTRAIT.AI_ARCHER,
	Game.TYPE.MAGE: Dialogue.PORTRAIT.AI_MAGE,
	Game.TYPE.FIGHTER: Dialogue.PORTRAIT.AI_SWORDSMAN
}

func _init(character, personality = null):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if personality == null:
		personality = rng.randi_range(0, 3)
	self.personality = personality
	self.character = character
	var num_intros = introductions[personality].size()
	intro = Dialogue.new()
	intro.title = character.name
	intro.text = introductions[personality][rand_range(0, num_intros)]
	intro.portrait = portrait_map[character.character_class]
	intro.branches.append(generate_branch(PERSONALITY.AGGRESSIVE))
	intro.branches.append(generate_branch(PERSONALITY.NARCISSIST))
	intro.branches.append(generate_branch(PERSONALITY.GREEDY))
	intro.branches.shuffle()
	intro.connect("completed", self, "_on_branch")

func _on_branch(id):
	print("branch ", id)
	if id == self.personality:
		self.emit_signal("response", generate_response(true))
	else:
		self.emit_signal("response", generate_response(false))

func generate_branch(personality):
	var branch = Dialogue.new()
	var num_responses = persuasion[personality].size()
	branch.text = persuasion[personality][rand_range(0, num_responses)]
	branch.dialogue_id = personality
	return branch
	
func generate_response(accepted):
	var response = Dialogue.new()
	var num_options = accept[personality].size()
	if not accepted:
		num_options = deny[personality].size()
		response.text = deny[personality][rand_range(0, num_options)]
		response.dialogue_id = "denied"
	else:
		response.text = accept[personality][rand_range(0, num_options)]
		response.dialogue_id = "accepted"
	response.title = character.name
	response.portrait = portrait_map[character.character_class]
	return response
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
