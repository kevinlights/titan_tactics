extends Camera

var start_time = 0
var start_offset = Vector3()
var start_rotation = Vector3()
var end_offset = Vector3()
var end_rotation = Vector3()

var ttl = 300
var move_ttl = 500

var target_position = Vector3()
var move_time = 0
var move_start = Vector3()

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
	print("Camera now tracks ", item.name)
	var now = OS.get_ticks_msec()
	if tracked_item:
		move_time = now
		move_start = get_parent().translation
	tracked_item = item

func _ready():
	# warning-ignore:return_value_discarded
	Game.connect("orientation_changed", self, "_on_orientation_changed")
	Game.connect("orientation_changed_clockwise", self, "_on_orientation_changed_clockwise")
	Game.connect("orientation_changed_counter_clockwise", self, "_on_orientation_changed_counter_clockwise")
#	_on_orientation_changed()

func _on_orientation_changed_clockwise():
	var now = OS.get_ticks_msec()
#	if now - start_time < ttl:
#		end_rotation += Vector3(0, 90, 0) 
#		start_time += ttl #(now - start_time) 
#		return
	start_time = now
	start_rotation = get_parent().rotation_degrees
	end_rotation = start_rotation + Vector3(0, 90, 0) # rotations[Game.camera_orientation]

func _on_orientation_changed_counter_clockwise():
	var now = OS.get_ticks_msec()
#	if now - start_time < ttl:
#		end_rotation -= Vector3(0, 90, 0) # rotations[Game.camera_orientation]
#		start_time += ttl 
#		return
	start_time = now
	start_rotation = get_parent().rotation_degrees
	end_rotation = start_rotation - Vector3(0, 90, 0) # rotations[Game.camera_orientation]
	
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
	var now = OS.get_ticks_msec()
	return now - start_time < ttl

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
