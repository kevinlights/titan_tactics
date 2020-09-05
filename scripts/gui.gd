extends CanvasLayer

var active = false
var modal = false

var exempt = [ "sfx", "playerturn", "enemyturn" ]

func _ready():
	$pause.connect("resume", self, "back")
	$pause.connect("quit", get_tree(), "change_scene", [ "res://scenes/landing.tscn" ])
	$lose.connect("quit", get_tree(), "change_scene", [ "res://scenes/landing.tscn" ])
	$lvlup.connect("close", self, "_close_level_up")


func _close_level_up():
	print("run turn end ui")
	modal = false
	var world = get_tree().get_root().get_node("World")
	turn(world.current_turn)

func _input(event):
	if not modal and event.is_action("ui_cancel") && !event.is_echo() && event.is_pressed():
		$sfx/close.play()
		back()
	if not modal and event.is_action("ui_end") && !event.is_echo() && event.is_pressed():
		pause()
	if active:
		if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
			$sfx/open.play()
		if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
			$sfx/open.play()
		if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
			$sfx/select.play()

func attack():
	active = true
#	$healthpage.call_deferred("hide")
	$battle.call_deferred("hide")
	$action_menu.call_deferred("show_dialog", "attack")

func turn(type):
	if $lvlup.visible:
		return
	active = true
	match type:
		Game.CONTROL.PLAYER:
			$playerturn.reset()
			$playerturn.show()
		Game.CONTROL.AI:
			$enemyturn.reset()
			$enemyturn.show()

func credits():
	active = true
	$credits.show()

func close_attack():
	active = false
	$action_menu.hide()

func team_select(characters):
	modal = true
	$characterselect.set_characters(characters)
	$characterselect.show()

func intro(description):
	$intro.display(description)

func error(message):
	$sfx/denied.play()

func level_up(diff, new_stats):
	active = true
	modal = true
	$lvlup.on_level_up(diff, new_stats)
	$lvlup.call_deferred("show")
	$sfx/level_up.play()
	
func battle(friendly, enemy):
	$battle.set_entities(friendly, enemy)
	$battle.show()

func battle_hide(current):
	$battle.start_hiding(current)
	#$battle/box_ally.position.x = $battle.start_x_ally
	#$battle/box_enemy.position.x = $battle.start_x_enemy

func loot(current, new, type):
	active = true
	$weaponswap.set_weapons(current, new, type)
	$weaponswap.show()

#func health(friendly, enemy):
#	if !modal:
#		print(enemy.character.hp)
#		print(enemy.character.max_hp)
#		$healthpage.set_entities(friendly.character, enemy.character)
#		$healthpage.show()

func team_confirm():
	active = true
	$teamconfirm.call_deferred("show_dialog")

func win():
	active = true
	$win.reset()
	$win/Control/Next.grab_focus()
	$win.show()

func lose():
	active = true
	$lose.reset()
	$lose/Control/Retry.grab_focus()
	$lose.show()

func guard(is_healer = false):
	active = true
	if is_healer:
		$action_menu.call_deferred("show_dialog", "heal")
	else:
		$action_menu.call_deferred("show_dialog", "guard")

func pause():
	$sfx/select.play()
	active = true
	$pause.show_dialog()

func close(dialog):
	active = false
	get_node(dialog).hide()

func back():
	active = false
	for dialog in get_children():
		if not exempt.has(dialog.name):
			dialog.hide()

func dialogue(content):
	back()
	modal = true
	active = true
	print(content.text)
	$dialogue.set_content(content)
	$dialogue.show()
