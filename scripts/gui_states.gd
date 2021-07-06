class_name GuiStates
extends CanvasLayer

signal selector_left
signal selector_right
signal selector_up
signal selector_down
signal aoe_left
signal aoe_right
signal aoe_up
signal aoe_down

var current
var non_blocking = [ "battle", "ally" ]
var cant_cancel = [ "win", "fin", "lose", "lvlup", "credits", "dialogue_box" ]

var queued = []

func back():
	if current:
		if "name" in current:
			print("[GUI] unset gui (currently: ", current.name,")")
		else:
			print("[GUI] unset gui (but it hat no name.)")
		# deferred because 'out' may trigger a gui change
		current.call_deferred("out")
		self.current = null
	else:
		print("[GUI] Close gui - but none seems to be open")
	# control is being returned to player - set contextual ui
	if queued.size() == 0 and get_parent().current_turn == TT.CONTROL.PLAYER:
		print("[GUI] queue empty, setting contextual UI, if any.")
		get_parent().call_deferred("contextual_ui")

func close(names:Array):
	if current and current.name in names:
		current.call_deferred("out")
		current = null

func is_blocking():
	if !current:
		return false
	return !(current.name in non_blocking)

func start(name, arg=null):
	print ("[GUI] set state ", name)
	var node = get_node(name)
	if current:
		print("[GUI] Current: ", current.name)
		if !(current.name in non_blocking):
			if !(name in queued) and current.name != name:
				print("[GUI] Queueing ui state ", name)
				queued.append({ "name": name, "arg": arg })
				current.connect("closed", self, "next", [], CONNECT_ONESHOT)
				return
			else:
				print("[GUI] warning - requested queue for ", name, " but it is already active or queued.")
		current.call_deferred("out")
	node.call_deferred("init", arg)
	current = node

func next():
	print("[GUI] start next queued")
	if queued.size() > 0:
		var next_ui = queued.pop_back()
		start(next_ui.name, next_ui.arg)

func _input(event):
	if (!current or current.name in non_blocking) and get_parent().current_turn == TT.CONTROL.PLAYER:
		var character = get_parent().get_current()
		if character.character.character_class == TT.TYPE.FIGHTER and get_parent().mode == TacticsWorld.MODE.SECONDARY_ATTACK:
			if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
				emit_signal("aoe_down")
				print("[INPUT] aoe_down")
			if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
				emit_signal("aoe_up")
				print("[INPUT] aoe_up")
			if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
				emit_signal("aoe_left")
				print("[INPUT] aoe_left")
			if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
				emit_signal("aoe_right")
				print("[INPUT] aoe_right")
		else:
			if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
				emit_signal("selector_down")
			if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
				emit_signal("selector_up")
			if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
				emit_signal("selector_left")
			if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
				emit_signal("selector_right")
		if get_parent().mode == TacticsWorld.MODE.PLAY:
			if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
				get_parent().action()
			if event.is_action("character_switch") && !event.is_echo() && event.is_pressed():
				if get_parent().current[TT.CONTROL.PLAYER].size() > 1:
					start("characterswap")
			if event.is_action("context_menu") && !event.is_echo() && event.is_pressed():
				var current = get_parent().get_current()
				if current:
					start("action_menu", current.character.character_class)
#				if get_parent().get_current().character.turn_limits.actions > 0:
#					var ability = "guard"
#					if get_parent().get_current().character.has_ability(TT.ABILITY.HEAL):
#						ability = "heal"
#					start("action_menu", ability)
#				else:
#					start("action_menu", "end")
		elif get_parent().mode == TacticsWorld.MODE.CHECK_MAP:
			if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
				start("teamconfirm")
			if event.is_action("character_switch") && !event.is_echo() && event.is_pressed():
				start("teamconfirm")
			if event.is_action("context_menu") && !event.is_echo() && event.is_pressed():
				start("teamconfirm")
	if get_parent().mode == TacticsWorld.MODE.ATTACK or get_parent().mode == TacticsWorld.MODE.HEAL or get_parent().mode == TacticsWorld.MODE.SECONDARY_ATTACK:
		if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
			get_parent().action()
		if event.is_action("context_cancel") && !event.is_echo() && event.is_pressed():
			get_parent().set_mode(TacticsWorld.MODE.PLAY)
	if get_parent().mode == TacticsWorld.MODE.PLAY:
		if event.is_action("context_cancel") && !event.is_echo() && event.is_pressed():
			if !current or (current.name in non_blocking):
				get_parent().get_current().undo_walk()
			if current and !(current.name in cant_cancel):
				back()
		if event.is_action("pause_game") && !event.is_echo() && event.is_pressed():
			start("pause")


