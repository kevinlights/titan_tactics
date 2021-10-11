extends Control

var playeratk
var playerdef
var playerlvl
var playerhp
var playername
var player

var ttl = 100

var start_x_ally = -160
var end_x_ally = 0
var bar_size = 80
var xp_bar_size = 35

var moving_back = false

var start

onready var world = get_tree().get_root().get_node("World")

var default_portraits = {
	TT.TYPE.ARCHER: "archer",
	TT.TYPE.MAGE: "mage",
	TT.TYPE.FIGHTER: "swordsman"
}

func _process(_delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	if player:
		$box_ally/levelline.set_point_position(1, Vector2((player.character.current_to_next/player.character.xp_to_next)*xp_bar_size, 0))
	#move hp line
	if $box_ally/hpline.get_point_position(1).x > (player.character.hp/player.character.max_hp)*bar_size:
		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x - 0.5, 0)
		$box_ally/hpline.set_point_position(1, new_hp_pos)
	if $box_ally/hpline.get_point_position(1).x < (player.character.hp/player.character.max_hp)*bar_size:
		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x + 0.5, 0)
		$box_ally/hpline.set_point_position(1, new_hp_pos)
	
	if !moving_back:
		if now - start < ttl:
			$box_ally.position.x = lerp(start_x_ally, end_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = end_x_ally
	else:
		if now - start < ttl:
			$box_ally.position.x = lerp(end_x_ally, start_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = start_x_ally
			hide()

func _ready():
	$box_ally.position.x = start_x_ally
	moving_back = false

func update_stats(update_player):
	self.player = update_player
	playerhp = player.character.hp
	if playerhp < 0:
		playerhp = 0
	playerhp = str(playerhp)  + "/" + str(player.character.max_hp)
	playerlvl = player.character.level
	playeratk = int(round(player.character.atk+ player.character.item_atk.attack))
	playerdef = int(round(player.character.def + player.character.item_def.defense))
	$box_ally/playername.text = player.character.name
	$box_ally/playeratklevel.text = str(playeratk)
	$box_ally/playerdeflevel.text = str(playerdef)
	$box_ally/playerlevel.text = str(playerlvl)
	$box_ally/playerhp.text = (playerhp)
	if player.character.portrait_override and player.character.portrait_override != "":
		$box_ally/portraits.play(player.character.portrait_override)
	else:
		$box_ally/portraits.play(default_portraits[player.character.character_class])

func init(arg):
	print("[ALLY] show")
	moving_back = false
	var current_character = arg
	update_stats(current_character)
	start = OS.get_ticks_msec()
	show()

func out():
	print("[ALLY] hide")
	moving_back = true
	start = OS.get_ticks_msec()
