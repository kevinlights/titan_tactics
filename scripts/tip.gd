extends Control

onready var world = get_parent().get_parent()

func get_characters_with_actions():
	var num_done = 0
	for character_check in world.current[TT.CONTROL.PLAYER]:
		if character_check.is_done:
			num_done += 1
	return world.current[TT.CONTROL.PLAYER].size() - num_done

func _process(delta):
	if world.current_turn == TT.CONTROL.AI:
		hide()
	else:
		show()
	if world.current[TT.CONTROL.PLAYER].size() == 1 or get_characters_with_actions() < 2:
		$AnimatedSprite.hide()
		$tip.hide()
	else:
		$AnimatedSprite.show()
		$tip.show()
