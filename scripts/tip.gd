extends Control

onready var world = get_parent().get_parent()

func _process(delta):
	if world.current_turn == TT.CONTROL.AI or get_parent().active:
		hide()
	else:
		show()
	if world.current[world.current_turn].size() == 1 or world.num_done < 2:
		$AnimatedSprite.hide()
		$tip.hide()
	else:
		$AnimatedSprite.show()
		$tip.show()
