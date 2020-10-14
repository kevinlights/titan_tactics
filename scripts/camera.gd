extends Camera

var offset = Vector3(-31.5, 32, 36.5)
var tracked_item

func track(item):
	tracked_item = item

func _process(delta):
	if tracked_item:
		translation = tracked_item.translation + offset
