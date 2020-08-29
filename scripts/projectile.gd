extends CPUParticles2D

signal hit

var start_position = Vector2(0, 0)
var end_position = Vector2(64, 64)
var start = 0
var ttl = 500

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
		position.x = lerp(start_position.x, end_position.x, float(now - start) / float(ttl))
		position.y = lerp(start_position.y, end_position.y, float(now - start) / float(ttl))
	else:		
		emit_signal("hit")
		get_parent().remove_child(self)
