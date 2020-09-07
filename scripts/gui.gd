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
	if $battle.visible:
		yield(get_tree().create_timer(2.0), "timeout")
		battle_hide()
	match type:
		Game.CONTROL.PLAYER:
			#battle_hide($battle.player)
			yield(get_tree().create_timer(1.0), "timeout")
			print("show turn for player")
			$playerturn.reset()
			$playerturn.show()
		Game.CONTROL.AI:
			#yield(get_tree().create_timer(0.0), "timeout")
			print("show turn for AI")
			$enemyturn.reset()
			$enemyturn.show()
	get_parent().get_node("select").disable()

func credits():
	active = true
	$credits.show()

func close_attack():
	active = false
	$action_menu.hide()

func arrow_hide():
	get_parent().get_node("select/select").hide()
	
func make_select_blank():
	get_parent().get_node("select").play("blank")

func team_select(characters):
	modal = true
	active = true
	get_parent().get_node("select/select").show()
	$characterswap.hide()
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
	if !$battle.visible:
		$battle.set_entities(friendly, enemy)
		$battle.show()
	
func ally(friendly):
	$ally.set_entities(friendly)
	$ally.show()
	
func ally_hide(current):
	$ally.start_hiding(current)

func battle_hide(current = null):
	print("Hide battle UI")
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
	arrow_hide()
	$teamconfirm.call_deferred("show_dialog")

func swap():
	ally_hide(get_parent().get_current())
	active = true
	get_parent().get_node("select/select").show()
	get_parent().get_node("select").disable()
	$characterswap.start = OS.get_ticks_msec()
	$characterswap._input(null)
	$characterswap.show()
	

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
