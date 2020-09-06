extends Node

enum TYPE { FIGHTER, ARCHER, MAGE, OTHER }
#enum TYPE { ARCHER, MAGE, FIGHTER }
enum ABILITY { MOVE, ATTACK, GUARD, HEAL }
enum CONTROL { PLAYER, AI }
enum CONTEXT {
	ATTACK,
	GUARD,
	MOVE,
	HEAL,
	NEUTRAL,
	USE,
	NOT_ALLOWED,
	NOT_PLAYABLE
}

const cell_size = 16
const levels = {
	"level_0": "intro",
	"level_1": "forest",
	"level_2": "forest",
	"level_3": "forest",
	"level_4": "cave",
	"level_5": "cave",
	"level_6": "cave",
	"level_7": "city",
	"level_8": "city",
	"level_9": "city",
	"level_10": "city"
}

const character_names = [
	"Amy",
	"Ani",
	"Arev",
	"Arie",
	"Bart",
	"Bella",
	"Bram",
	"Ciara",
	"Clyde",
	"Cyndi",
	"Daft",
	"Dara",
	"Dario",
	"Datev",
	"Deal",
	"Diego",
	"Dirk",
	"Edd",
	"Eva",
	"Firas",
	"Flan",
	"Flo",
	"Gabi",
	"Gwen",
	"Hayk",
	"Hope",
	"Horm",
	"Izzy",
	"Jake",
	"Jason",
	"Jenna",
	"Jonn",
	"Joss",
	"Kadif",
	"Kara",
	"Kelly",
	"Kris",
	"Laura",
	"Layla",
	"Lily",
	"Liz",
	"Lokum",
	"Lorre",
	"Lota",
	"Mags",
	"Malik",
	"Marci",
	"Marie",
	"Marv",
	"Max",
	"Minfu",
	"Momo",
	"Morg",
	"Nell",
	"Nikk",
	"Norr",
	"Nord",
	"Nugat",
	"Ozzy",
	"Petr",
	"Quinn",
	"Rafe",
	"Rash",
	"Rina",
	"Rinky",
	"Rolf",
	"Ronn",
	"Ruth",
	"Sage",
	"Sandi",
	"Seth",
	"Shawn",
	"Sid",
	"Silva",
	"Tarek",
	"Tim",
	"Vart",
	"Vince",
	"Yava",
	"Nina",
	"Mikk",
	"Lynn",
	"Nedd",
	"Stik",
	"Kit",
	"Wil",
	"Pop",
	"Jax",
	"Sonn",
	"Cari",
	"Jessi",
	"Alf",
	"Gor",
	"Nora",
	"Toni",
	"Anita",
	"Ward",
	"Cyrus",
	"Kane",
	"Symon",
	"Mac",
	"Rory",
	"Neil",
	"Steph",
	"Trina",
	"Kurt"
]

# mage > fighter > archer

const class_stats = {
	"weakness": {
		TYPE.FIGHTER: TYPE.MAGE,
		TYPE.ARCHER: TYPE.FIGHTER,
		TYPE.MAGE: TYPE.ARCHER
	},
	"strength": {
		TYPE.MAGE: TYPE.FIGHTER,
		TYPE.FIGHTER: TYPE.ARCHER,
		TYPE.ARCHER: TYPE.MAGE
	},
	"abilities": {
		TYPE.ARCHER: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.GUARD ],
		TYPE.FIGHTER: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.GUARD ],
		TYPE.MAGE: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.HEAL ]
	}
}

var team = []
var level = 0
var sudden_death = false

func get_level_count():
	return levels.keys().size()

func get_level():
	var names = levels.keys()
	return names[level]

func get_theme():
	var lvl = get_level()
	return levels[lvl]

func _ready():
	var default_stats = load("res://resources/class_stats.tres")
	var character = CharacterStats.new()
#	character.from_defaults(TYPE.FIGHTER, CONTROL.PLAYER)
	character.generate(default_stats, TYPE.FIGHTER, CONTROL.PLAYER, 1, true)
	character.name = "Rolf"
	character.portrait_override = Dialogue.PORTRAIT.HERO
	team.append(character)
	
