extends Camera

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
	offset = offsets[Game.camera_orientation]
	rotation_degrees = rotations[Game.camera_orientation]

func _process(_delta):
	if tracked_item:
		translation = tracked_item.translation + offset
