extends Camera

var offset = Vector3(15, 19, -15)
var tracked_item

func track(item):
	tracked_item = item

func _process(delta):
	if tracked_item:
		translation = tracked_item.translation + offset
