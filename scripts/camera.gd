extends Camera

var is_cutscene = false
var start_time = 0
var start_offset = Vector3()
var start_rotation = Vector3()
var end_offset = Vector3()
var end_rotation = Vector3()
var rotating = false
var ttl = 150
var move_ttl = 500
var last_rotation = Vector3()

var target_position = Vector3()
var move_time = 0
var move_start = Vector3()

var cutscene_offset = Vector3(-15, 12, 15)
var cutscene_rotation = Vector3(-20, -45, 0)

var offsets = {
	TT.CAMERA.SOUTH: Vector3(15, 19, -15),
	TT.CAMERA.NORTH: Vector3(-15, 19, 15),
	TT.CAMERA.EAST: Vector3(-15, 19, -15),
	TT.CAMERA.WEST: Vector3(15, 19, 15),
}

var rotations = {
	TT.CAMERA.SOUTH: Vector3(-40, 135, 0),
	TT.CAMERA.NORTH: Vector3(-40, -45, 0),
	TT.CAMERA.WEST: Vector3(-40, 45, 0),
	TT.CAMERA.EAST: Vector3(-40, -135, 0),
}

var tracked_item

var offset = offsets[Game.camera_orientation]

func track(item):
	if item:
		if "character" in item:
			print("[Camera] now tracking ", item.character.name)
		else:
			print("[Camera] now tracking ", item.name)
		var now = OS.get_ticks_msec()
		if tracked_item:
			move_time = now
			move_start = get_parent().translation
		tracked_item = item

func _ready():
	get_tree().get_root().get_node("World/gui/dialogue_box").connect("cutscene_start", self, "_on_cutscene_start")
	get_tree().get_root().get_node("World/gui/dialogue_box").connect("cutscene_end", self, "_on_cutscene_end")
	# warning-ignore:return_value_discarded
	Game.connect("orientation_changed", self, "_on_orientation_changed")
# warning-ignore:return_value_discarded
	Game.connect("orientation_changed_clockwise", self, "_on_orientation_changed_clockwise")
# warning-ignore:return_value_discarded
	Game.connect("orientation_changed_counter_clockwise", self, "_on_orientation_changed_counter_clockwise")
#	_on_orientation_changed()

func _on_cutscene_start():
	var now = OS.get_ticks_msec()
	is_cutscene = true
	start_time = now
	last_rotation = get_parent().rotation_degrees
	start_rotation = get_parent().rotation_degrees
	cutscene_rotation.y = start_rotation.y
	end_rotation = start_rotation + Vector3(5, 0, 5)
	rotating = true
	

func _on_cutscene_end():
	is_cutscene = false
	var now = OS.get_ticks_msec()
	is_cutscene = true
	start_time = now
	start_rotation = get_parent().rotation_degrees
	end_rotation = start_rotation + Vector3(-5, 0, -5)
	rotating = true
	
	
func _on_orientation_changed_clockwise():
#	if is_cutscene:
#		return
	var now = OS.get_ticks_msec()
#	if now - start_time < ttl:
#		end_rotation += Vector3(0, 90, 0) 
#		start_time += ttl #(now - start_time) 
#		return
	start_time = now
	start_rotation = get_parent().rotation_degrees
	end_rotation = start_rotation + Vector3(0, 90, 0) # rotations[Game.camera_orientation]
	rotating = true

func _on_orientation_changed_counter_clockwise():
#	if is_cutscene:
#		return
	var now = OS.get_ticks_msec()
#	if now - start_time < ttl:
#		end_rotation -= Vector3(0, 90, 0) # rotations[Game.camera_orientation]
#		start_time += ttl 
#		return
	start_time = now
	start_rotation = get_parent().rotation_degrees
	end_rotation = start_rotation - Vector3(0, 90, 0) # rotations[Game.camera_orientation]
	rotating = true
	
func _on_orientation_changed():
	pass
#	start_time = OS.get_ticks_msec()
##	start_offset = offset
##	end_offset = offsets[Game.camera_orientation]
#	start_rotation = get_parent().rotation_degrees
#	end_rotation = start_rotation + Vector3(0, 90, 0) # rotations[Game.camera_orientation]
##	if start_rotation.y == 135 and end_rotation.y == -135:
##		end_rotation.y = 225
##	if start_rotation.y == -135 and end_rotation.y == 135:
##		end_rotation.y = -225
#	print(Game.camera_orientation)
#	print(start_rotation)

func is_rotating():
	return rotating
#	var now = OS.get_ticks_msec()
#	return now - start_time < ttl

func _process(_delta):
	var now = OS.get_ticks_msec()
	if tracked_item:
		if now - move_time < move_ttl:
			get_parent().translation = lerp(move_start, tracked_item.get_global_transform().origin, float(now - move_time) / float(move_ttl))
		else:
			get_parent().translation = tracked_item.get_global_transform().origin;
		get_parent().translation.y = -1.0
	else:
		tracked_item = get_tree().get_root().get_node("World").get_current()
	if now - start_time < ttl:
		get_parent().rotation_degrees = lerp(start_rotation, end_rotation, float(now - start_time) / float(ttl))
	else:
		get_parent().rotation_degrees = end_rotation
		rotating = false
#	if is_cutscene and now - start_time < ttl:
#		translation.y = lerp(19, 20, float(now - start_time) / float(ttl))
#	if not is_cutscene and translation.y != 19:
#		translation.y = lerp(20, 19, float(now - start_time) / float(ttl))
