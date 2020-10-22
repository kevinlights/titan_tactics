extends Control

onready var world = get_parent().get_parent()

func _process(delta):
	if world.current_turn == TT.CONTROL.AI or get_parent().active or world.current[world.current_turn].size() == 1 or world.num_done < 2:
		hide()
	else:
		show()
