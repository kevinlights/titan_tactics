extends AnimatedSprite

signal moved

onready var world = get_tree().get_root().get_node("World")
onready var gui = get_tree().get_root().get_node("World/gui")

enum MODE {
	PLAY,
	CHECK_MAP
}

var mode = MODE.PLAY
var tile = Vector2(0, 0) setget set_tile, get_tile
var current_entity
var disabled = false

var current_target = {
	"tile": Vector2(0, 0),
	"entity": null
}

func set_tile(p_tile):
	position.x = p_tile.x * Game.cell_size
	position.y = p_tile.y * Game.cell_size

func get_tile():
	tile =  Vector2(floor(position.x / Game.cell_size), floor(position.y / Game.cell_size))
	tile.x = clamp(tile.x, 0, world.map_size.width - 1)
	tile.y = clamp(tile.y, 0, world.map_size.height - 1)
	return tile

func disable():
	print("disable selector")
	disabled = true

func enable():
	print("enable selector")
	disabled = false
	set_context(world.get_current_context(tile))

func set_context(context):
	if world.current_turn == Game.CONTROL.AI or context == Game.CONTEXT.NOT_PLAYABLE:
		print("context is not playable, hiding selector")
		play("blank")
		return
	match(context):
		Game.CONTEXT.USE:
			play("attack")
		Game.CONTEXT.ATTACK:
			play("attack")
		Game.CONTEXT.GUARD:
			play("guard")
		Game.CONTEXT.HEAL:
			play("heal")
		Game.CONTEXT.MOVE:
			play("default")
		Game.CONTEXT.NOT_ALLOWED:
			play("cantmove")

func _input(event):
	var advance = Vector2(0, 0)
	if world.get_current_context(tile) == Game.CONTEXT.NOT_PLAYABLE:
		play("blank")
		return
	if gui.active or disabled:
		if not world.current_turn == Game.CONTROL.AI:
			play("attack")
			return
	if world.current_turn == Game.CONTROL.AI:
		play("blank")
		return
	if event.is_action("ui_cancel") && !event.is_echo() && event.is_pressed() and !get_parent().get_node("gui").active:
		set_origin(get_parent().get_current())
		get_parent().get_node("path_preview/path").clear_points()
		get_parent().change_character()
		return
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
		advance.y = 1
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
		advance.y = -1
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
		advance.x = -1
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
		advance.x = 1
	self.tile = self.tile + advance
	if not advance.is_equal_approx(Vector2(0, 0)):
		emit_signal("moved", self.tile)
	
	if mode == MODE.PLAY:
		if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
			world.action()
		if event.is_action("ui_select") && !event.is_echo() && event.is_pressed():
			gui.call_deferred("back")
	else:
		if event.is_action("ui_accept") && !event.is_echo() && event.is_pressed():
			gui.team_confirm()
			disable()
		if animation != "attack":
			play("attack")

func go_home():
	self.tile = current_entity.tile
	if world.current_turn == Game.CONTROL.AI:
		emit_signal("moved", self.tile)

func set_origin(entity):
	if current_entity:
		current_entity.disconnect("idle", self, "go_home")
	current_entity = entity
	position = entity.position
	current_entity.select()
	current_entity.connect("idle", self, "go_home")
