extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play():
	show()
	$AnimationPlayer.current_animation = "Thunder storm"
	$Spark.emitting = true
	$Thunder.play()
	$Flash.show()
	yield(get_tree().create_timer(1.0), "timeout")
	$Flash.hide()
	hide()
