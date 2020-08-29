extends Node2D

var start
var start_y = 0
var ttl = 400

func _ready():
	start = OS.get_ticks_msec()
	start_y = position.y

func _process(delta):
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		position.y = lerp(start_y, start_y - 8, float(now - start) / float(ttl))
		var modulate = Color(1, 1, 1, lerp(1, 1, float(now - start) / float(ttl)))
		set("modulate", modulate)
	else:
		get_parent().remove_child(self)
