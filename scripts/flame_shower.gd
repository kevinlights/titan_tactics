extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play():
	show()
	$AnimationPlayer.current_animation = "Thunder storm"
	$RainOfDeath.play()
	yield(get_tree().create_timer(1.0), "timeout")
	hide()
