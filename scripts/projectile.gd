extends CPUParticles

signal hit

var start_position = Vector3(0, 0, 0)
var end_position = Vector3(64, 0, 64)
var start = 0
var ttl = 750

# Called when the node enters the scene tree for the first time.
func _ready():
	start = OS.get_ticks_msec()

func fire(from, to):
	start = OS.get_ticks_msec()
	start_position = from
	end_position = to

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	if now - start < ttl:
		translation = lerp(start_position, end_position, float(now - start) / float(ttl))
#		translation.z = lerp(start_position.z, end_position.z, float(now - start) / float(ttl))
	else:		
		emit_signal("hit")
		hide()
		yield(get_tree().create_timer(1.0), "timeout")
		get_parent().remove_child(self)
