class_name TT
extends Node

const sudden_death = false

enum TYPE { FIGHTER, ARCHER, MAGE, OTHER }
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

const cell_size = 1
const levels = [
	{
		"name": "Rolf the Confused",
		"scene": "level_1_3dtest",
		"music": "forest"
	},
	{
		"name": "The OGRE enters the game",
		"scene": "level_2_3dtest",
		"music": "forest"
	},
	{
		"name": "Roses are red, Violets are blue...",
		"scene": "level_1_3dtest",
		"music": "forest"
	},
	{
		"name": "We all scream for ice cream",
		"scene": "level_1_3dtest",
		"music": "cave"
	},
	{
		"name": "Viva la libertad",
		"scene": "level_1_3dtest",
		"music": "cave"
	},
	{
		"name": "The well is not well",
		"scene": "level_1_3dtest",
		"music": "cave"
	},
	{
		"name": "The hole is not whole",
		"scene": "level_1_3dtest",
		"music": "cave"
	},
	{
		"name": "Meat is murder. Delicious, delicious murder.",
		"scene": "level_1_3dtest",
		"music": "city"
	},
	{
		"name": "The end of the rainbow",
		"scene": "level_1_3dtest",
		"music": "city"
	},
	{
		"name": "The pot of gold",
		"scene": "level_1_3dtest",
		"music": "city"
	}
]
#const levels = {
#	"level_1_3dtest": "intro",
#	"level_0": "intro",
#	"level_1": "forest",
#	"level_2": "forest",
#	"level_3": "forest",
#	"level_4": "cave",
#	"level_5": "cave",
#	"level_6": "cave",
#	"level_7": "city",
#	"level_8": "city",
#	"level_9": "city",
#	"level_10": "city"
#}

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

