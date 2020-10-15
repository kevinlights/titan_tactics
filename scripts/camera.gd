extends Camera

var start_time = 0
var start_offset = Vector3()
var start_rotation = Vector3()
var end_offset = Vector3()
var end_rotation = Vector3()

var ttl = 500

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
	tracked_item = item

func _ready():
	# warning-ignore:return_value_discarded
	Game.connect("orientation_changed", self, "_on_orientation_changed")
	_on_orientation_changed()

func _on_orientation_changed():
	start_time = OS.get_ticks_msec()
	start_offset = offset
	end_offset = offsets[Game.camera_orientation]
	start_rotation = rotation_degrees
	end_rotation = rotations[Game.camera_orientation]
	if start_rotation.y == 135 and end_rotation.y == -135:
		end_rotation.y = 225
	if start_rotation.y == -135 and end_rotation.y == 135:
		end_rotation.y = -225
	print(Game.camera_orientation)
	print(start_rotation)

func _process(_delta):
	var now = OS.get_ticks_msec()
	if now - start_time < ttl:
		offset = lerp(start_offset, end_offset, float(now - start_time) / float(ttl))
		rotation_degrees = lerp(start_rotation, end_rotation, float(now - start_time) / float(ttl))
	else:
		rotation_degrees = rotations[Game.camera_orientation]
		offset = end_offset
	if tracked_item:
		translation = tracked_item.translation + offset
