extends AnimatedSprite3D

signal moved

onready var world = get_tree().get_root().get_node("World")
onready var gui = get_tree().get_root().get_node("World/gui")

var directions = {
	TT.CAMERA.NORTH: {
		"left": Vector3(-1, 0, 0),
		"right": Vector3(1, 0, 0),
		"up": Vector3(0, 0, -1),
		"down": Vector3(0, 0, 1)
	},
	TT.CAMERA.SOUTH: {
		"left": Vector3(1, 0, 0),
		"right": Vector3(-1, 0, 0),
		"up": Vector3(0, 0, 1),
		"down": Vector3(0, 0, -1)
	},
	TT.CAMERA.EAST: {
		"left": Vector3(0, 0, -1),
		"right": Vector3(0, 0, 1),
		"up": Vector3(1, 0, 0),
		"down": Vector3(-1, 0, 0)
	},
	TT.CAMERA.WEST: {
		"left": Vector3(0, 0, 1),
		"right": Vector3(0, 0, -1),
		"up": Vector3(-1, 0, 0),
		"down": Vector3(1, 0, 0)
	}
}

enum MODE {
	PLAY,
	CHECK_MAP
}


var camera_captured = false
var mode = MODE.PLAY
var tile = Vector3(0, 0, 0) setget set_tile, get_tile
var current_entity
var disabled = false

var current_target = {
	"tile": Vector3(0, 0, 0),
	"entity": null
}

func set_tile(p_tile):
	translation.x = p_tile.x + 0.5 # * TT.cell_size
	translation.z = p_tile.z + 0.5 # * TT.cell_size

func get_tile():
	tile =  Vector3(
		floor(translation.x),
		0,
		floor(translation.z)) # Vector3(floor(translation.x / TT.cell_size), 0, floor(translation.z / TT.cell_size))
#	tile.x = clamp(tile.x, 0, world.map_size.width - 1)
#	tile.z = clamp(tile.z, 0, world.map_size.height - 1)
	return tile

func disable():
	print("disable selector")
	disabled = true

func enable():
	print("enable selector")
	disabled = false
	set_context(world.get_current_context(tile))

func update_context():
	set_context(world.get_current_context(tile))

func set_context(context):
#	if world.current_turn == TT.CONTROL.AI or context == TT.CONTEXT.NOT_PLAYABLE:
#		print("context is not playable, hiding selector")
#		play("blank")
#		return
	$top.translation.y = 0.25
	match(context):
		TT.CONTEXT.USE:
			play("attack")
			$top.translation.y = 0.6
		TT.CONTEXT.ATTACK:
			play("attack")
			$top.translation.y = 1.0
		TT.CONTEXT.GUARD:
			play("guard")
			$top.translation.y = 1.0
		TT.CONTEXT.HEAL:
			play("heal")
			$top.translation.y = 1.0
		TT.CONTEXT.MOVE:
			play("default")
		TT.CONTEXT.NOT_ALLOWED:
			play("cantmove")

func _input(event):
	var advance = Vector3(0, 0, 0)
#	if world.get_current_context(tile) == TT.CONTEXT.NOT_PLAYABLE:
#		play("blank")
#		return
	if gui.active or disabled:
		if not world.current_turn == TT.CONTROL.AI:
			play("attack")
			return
	if world.current_turn == TT.CONTROL.AI:
		play("blank")
		return
	if event.is_action("ui_cancel") && !event.is_echo() && event.is_pressed() and !get_parent().get_node("gui").active:
		set_origin(get_parent().get_current())
		get_parent().get_node("path_preview/path").clear_points()
		get_parent().change_character()
		return
	if event.is_action("ui_down") && !event.is_echo() && event.is_pressed():
#		advance.z = 1
		advance = directions[Game.camera_orientation]["down"]
	if event.is_action("ui_up") && !event.is_echo() && event.is_pressed():
#		advance.z = -1
		advance = directions[Game.camera_orientation]["up"]
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
#		advance.x = -1
		advance = directions[Game.camera_orientation]["left"]
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
#		advance.x = 1
		advance = directions[Game.camera_orientation]["right"]
	self.tile = self.tile + advance
	if not advance.is_equal_approx(Vector3(0, 0, 0)):
		print("select tile ", tile)
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
	if world.current_turn == TT.CONTROL.AI:
		emit_signal("moved", self.tile)

func capture_camera():
	camera_captured = true
	world.get_node("camera").track(self)

func set_origin(entity):
	if current_entity:
		current_entity.disconnect("idle", self, "go_home")
	current_entity = entity
#	translation = entity.translation
	self.tile = entity.tile
	translation.y = 0.2
	print("Set origin ", translation)
	current_entity.select()
	current_entity.connect("idle", self, "go_home")
	capture_camera()
#
func _process(delta):
	$top/selector.rotation.y += delta * -3;
