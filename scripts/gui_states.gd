extends CanvasLayer

signal selector_left
signal selector_right
signal selector_up
signal selector_down

var current
var non_blocking = [ "battle", "ally" ]
var cant_cancel = [ "win", "lose", "lvlup" ]

var queued = []

func back():
	print("[GUI] unset gui")
	if current:
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
		if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
			emit_signal("selector_down")
		if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
			emit_signal("selector_up")
		if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
			emit_signal("selector_left")
		if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
			emit_signal("selector_right")
		if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
			get_parent().action()
	if event.is_action("context_cancel") && !event.is_echo() && event.is_pressed():
		if current and !(current.name in cant_cancel):
			back()

