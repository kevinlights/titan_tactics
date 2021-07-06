extends Spatial

signal hit

var start_position = Vector3(0, 0, 0)
var end_position = Vector3(1, 0, 0)
var start = 0
var ttl = 500
var is_gone = false

# Called when the node enters the scene tree for the first time.
func _ready():
	start = OS.get_ticks_msec()

func fire(from, to):
	start = OS.get_ticks_msec()
	start_position = from
	end_position = to
	$stick.look_at(end_position, Vector3.UP)
#	var angle = from.angle_to(to)
#	$stick.rotate(angle, Vector3(0, 1, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		translation = lerp(start_position, end_position, float(now - start) / float(ttl))
	else:
		emit_signal("hit")
		hide()
		yield(get_tree().create_timer(1.0), "timeout")
#		get_parent().remove_child(self)
		queue_free()
