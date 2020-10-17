extends AnimatedSprite

onready var world = get_tree().get_root().get_node("World")

var translation = Vector3(0, 0, 0) setget _set_translation, _get_translation

func _set_translation(new_translation):
#	world.get_node("camera").unproject_position(new_translation)
	translation = new_translation
	update_position()

func _get_translation():
	return translation

func update_position():
	position = world.get_node("camera").unproject_position(get_parent().translation + Vector3(0.5, 0, 0.5))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_position()
#	pass
