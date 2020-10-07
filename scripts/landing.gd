extends Node2D

var is_web = OS.get_name() == "HTML5"

func _input(event):	
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		$sfx/open.play()
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		$sfx/open.play()

func _ready():
	$music/theme.play()
	if Game.team.size() > 1:
		$menu/continue.show()
		$menu/continue.grab_focus()
	else:
		$menu/newgame.grab_focus()
#	$menu/credits/ok.connect("pressed", self, "_on_close_credits")
#	if is_web and $menu/margin/vbox/quit:
#		$menu/margin/vbox/quit.hide()

func _on_continue():
	$sfx/select.play()	
	yield(get_tree().create_timer(0.3), "timeout")		
	get_tree().change_scene("res://scenes/world_map.tscn")

func _on_close_credits():
	$sfx/select.play()	
	$menu/credits.hide()
	$menu/margin/vbox/credits.grab_focus()

func _on_credits():
	$sfx/select.play()
	$menu/credits.show() # ("show")
	$menu/credits/ok.grab_focus()

#	else:
#		$menu/credits.call_deferred("hide")

func _on_quit():
	$sfx/select.play()
	yield(get_tree().create_timer(0.25), "timeout")
	get_tree().quit()



func _on_newgame():
	Game.team = []
	Game._ready()
	_on_continue()
