extends Node

signal orientation_changed
signal orientation_changed_clockwise
signal orientation_changed_counter_clockwise

var team = []
var level = 0
var unlocked_level = 0
var camera_orientation = TT.CAMERA.NORTH setget set_camera_orientation, get_camera_orientation

var sfx = {}

var default_stats = load("res://resources/class_stats.tres")

func _ready() -> void:
	loadVA()

func loadVA():
	var d = Directory.new()
	d.change_dir("res://VA")
	d.list_dir_begin(true,true)
	var curD = d.get_next()
	while (curD != null && curD != ""):
		#print("[VAs] Checking: ",curD)
		if d.current_is_dir():
			var dd = Directory.new()
			dd.change_dir("res://VA/"+curD)
			dd.list_dir_begin(true,true)
			var curF = dd.get_next()
			while (curF != null && curF != ""):
				#print("[VAs] File: ",curF)
				var origF = curF
				curF = curF.to_lower()
				
				if curF.ends_with(".ogg.import"):
					curF = curF.replace('.import','')
					origF = origF.replace('.import','')
					var splt = curF.split("_")
					if not splt[0] in sfx:
						sfx[splt[0]] = {}
					if not splt[1] in sfx[splt[0]]:
						sfx[splt[0]][splt[1]] = {}
					if not splt[2] in sfx[splt[0]][splt[1]]:
						sfx[splt[0]][splt[1]][splt[2]] = {}
					if not splt[3] in sfx[splt[0]][splt[1]][splt[2]]:
						sfx[splt[0]][splt[1]][splt[2]][splt[3]] = {}
					if not splt[4] in sfx[splt[0]][splt[1]][splt[2]][splt[3]]:
						sfx[splt[0]][splt[1]][splt[2]][splt[3]][splt[4]] = []
					
					sfx[splt[0]][splt[1]][splt[2]][splt[3]][splt[4]].push_back(ResourceLoader.load("res://VA/"+curD+"/"+origF))
				curF = dd.get_next()
		curD = d.get_next()
	print_debug("[VAs] Loaded following VA files:", to_json(sfx))


func set_camera_orientation(new_orientation):

	if new_orientation > camera_orientation or (camera_orientation == TT.CAMERA.WEST and new_orientation == TT.CAMERA.NORTH):
		if not (camera_orientation == TT.CAMERA.NORTH and new_orientation == TT.CAMERA.WEST):
			camera_orientation = new_orientation
			emit_signal("orientation_changed_clockwise")
			print("orientation_changed_clockwise")
	if new_orientation < camera_orientation or (camera_orientation == TT.CAMERA.NORTH and new_orientation == TT.CAMERA.WEST):
		if not (camera_orientation == TT.CAMERA.WEST and new_orientation == TT.CAMERA.NORTH):
			camera_orientation = new_orientation
			emit_signal("orientation_changed_counter_clockwise")
			print("orientation_changed_counter_clockwise")
	camera_orientation = new_orientation
	emit_signal("orientation_changed")

func get_camera_orientation():
	return camera_orientation

func get_level_count():
	return TT.levels.size()

func get_level():
#	var names = TT.levels
	return TT.levels[level].scene

func get_theme():
#	var lvl = get_level()
	#return TT.levels[level].cutscene_music
	return TT.levels[level].music
#	return TT.levels[lvl]

func add_to_team(character):
	for existing in team:
		if existing.name == character.name:
			return
	team.append(character)
	
func setup_new_game():
	level = 0
	unlocked_level = 0
	team = []
	var kris = load("res://resources/cast/kris.tres")
	add_to_team(kris)
