extends Node2D

var is_web = OS.get_name() == "HTML5"

func _input(event):
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		$sfx/open.play()
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		$sfx/open.play()

func _ready():
	$music/theme.play()
	if SaveLoadSystem.has_save_file:
		$menu/continue.show()
		$menu/continue.grab_focus()
	else:
		$menu/continue.hide()
		$menu/newgame.grab_focus()
# warning-ignore:return_value_discarded
	$menu/credits_overlay/roll/ok.connect("pressed", self, "_on_close_credits")
#	if is_web and $menu/margin/vbox/quit:
#		$menu/margin/vbox/quit.hide()
	var filename = "res://resources/startup.json"
	var file = File.new()
	if file.file_exists(filename):
		file.open(filename, File.READ)
		var data = parse_json(file.get_as_text())
		Game.setup_new_game()
		Game.level = data.level
		get_tree().change_scene("res://scenes/world.tscn")
	else:
		print("No startup file, continuing normally")

func _on_continue():
	SaveLoadSystem.load_game()
	_start_game()

func _on_close_credits():
	$sfx/select.play()	
	$menu/credits_overlay.hide()
	$menu/credits.grab_focus()

func _on_quit():
	$sfx/select.play()
	yield(get_tree().create_timer(0.25), "timeout")
	get_tree().quit()

func _on_newgame():
	Game.setup_new_game()
	_start_game()

func _start_game():
	$sfx/select.play()
	yield(get_tree().create_timer(0.3), "timeout")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/world_map.tscn")
	


func _on_credits_pressed():
	$sfx/select.play()
	$menu/credits_overlay.show()
	$menu/credits_overlay/roll/ok.grab_focus()
	$menu/credits_overlay/roll/AnimationPlayer.current_animation = "roll"
