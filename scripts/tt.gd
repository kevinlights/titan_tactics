class_name TT
extends Node

const sudden_death = false

var camera_offset = Vector3(-6.5, 9, 6.5) # //Vector3(0, 8.8, 9)

enum CAMERA { 
	NORTH = 0, 
	EAST, 
	SOUTH, 
	WEST 
}

enum TYPE { FIGHTER, ARCHER, MAGE, BOBA, POISON_BOBA, OTHER }
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
		"scene": "level_1_3d",
		"music": "forest"
	},
	{
		"name": "The OGRE enters the game",
		"scene": "level_2_3d", #replace with level_2_3dtest if needed
		"music": "forest"
	},
	{
		"name": "Roses are red, Violets are blue...",
		"scene": "level_3_3d",
		"music": "forest"
	},
	{
		"name": "We all scream for ice cream",
		"scene": "level_4_3d",
		"music": "cave" #desert
	},
	{
		"name": "Viva la libertad",
		"scene": "level_5_3d",
		"music": "cave" #desert
	},
	{
		"name": "The well is not well",
		"scene": "level_6_3d",
		"music": "city" #ice
	},
	{
		"name": "The hole is not whole",
		"scene": "level_7_3d",
		"music": "city" #ice
	},
	{
		"name": "Meat is murder. Delicious, delicious murder.",
		"scene": "level_8_3d",
		"music": "city" #ice
	},
	{
		"name": "The end of the rainbow",
		"scene": "level_9_3d",
		"music": "cave" #desert
	},
	{
		"name": "The pot of gold",
		"scene": "level_10_3d",
		"music": "cave" #desert
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
		TYPE.MAGE: TYPE.ARCHER,
		TYPE.BOBA: TYPE.FIGHTER,
	},
	"strength": {
		TYPE.MAGE: TYPE.FIGHTER,
		TYPE.FIGHTER: TYPE.ARCHER,
		TYPE.ARCHER: TYPE.MAGE,
		TYPE.BOBA: TYPE.MAGE,
	},
	"abilities": {
		TYPE.ARCHER: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.GUARD ],
		TYPE.FIGHTER: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.GUARD ],
		TYPE.MAGE: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.HEAL ],
		TYPE.BOBA: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.HEAL ],
		TYPE.POISON_BOBA: [ ABILITY.MOVE, ABILITY.ATTACK, ABILITY.GUARD ]
	}
}

