extends Control


func _process(delta):
	if !get_parent().active:
		show()
	else:
		hide()
