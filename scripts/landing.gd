extends Node2D

var is_web = OS.get_name() == "HTML5"

#test comment

func _ready():
	$music/theme.play()
	$menu/margin/vbox/new_game.grab_focus()
	$menu/credits/margin/vbox/ok.connect("pressed", self, "_on_close_credits")
	if is_web and $quit:
		$menu/margin/vbox/quit.hide()

func _on_new_game():
	$sfx/select.play()	
	yield(get_tree().create_timer(0.3), "timeout")		
	get_tree().change_scene("res://scenes/world.tscn")

func _on_continue():
	_on_new_game()

func _on_close_credits():
	$menu/credits.hide()
	$menu/margin/vbox/credits.grab_focus()

func _on_credits():
	$menu/credits.show() # ("show")
	$menu/credits/margin/vbox/ok.grab_focus()

#	else:
#		$menu/credits.call_deferred("hide")

func _on_quit():
	pass
