extends Control

var playeratk
var playerdef
var playerlvl
var playerhp
var playername
var player
export(Array, String) var special_names

var ttl = 100

var start_x_ally = -30
var end_x_ally = 42

var moving_back = false

var start

var atlas_frames = {
	"up": 3,
	"down": 2,
	"neutral": 128,
	Game.TYPE.ARCHER: 2,
	Game.TYPE.FIGHTER: 0,
	Game.TYPE.MAGE: 4
}

#level line width = 28

func _process(delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	
	#move level line to the current exp
	if $box_ally/levelline.get_point_position(1).x > (player.character.xp/player.character.xp_to_next)*28:
		var new_lvl_pos = Vector2($box_ally/levelline.get_point_position(1).x - 0.5, 0)
		$box_ally/levelline.set_point_position(1, new_lvl_pos)
	if $box_ally/levelline.get_point_position(1).x < (player.character.xp/player.character.xp_to_next)*28:
		var new_lvl_pos = Vector2($box_ally/levelline.get_point_position(1).x + 0.5, 0)
		$box_ally/levelline.set_point_position(1, new_lvl_pos)
		
	#move hp line
	if $box_ally/hpline.get_point_position(1).x > (player.character.hp/player.character.max_hp)*61:
		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x - 0.5, 0)
		$box_ally/hpline.set_point_position(1, new_hp_pos)
	if $box_ally/hpline.get_point_position(1).x < (player.character.hp/player.character.max_hp)*61:
		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x + 0.5, 0)
		$box_ally/hpline.set_point_position(1, new_hp_pos)
	
	if !moving_back:
		#update_stats()
		if $box_ally.position.x < end_x_ally:
			$box_ally.position.x = lerp(start_x_ally, end_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = end_x_ally
	else:
		if $box_ally.position.x > start_x_ally:
			$box_ally.position.x = lerp(end_x_ally, start_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = start_x_ally
			hide()

func _ready():
	if not player:
		return
	moving_back = false
	$box_ally/hpline.set_point_position(1, Vector2(player.character.hp/player.character.max_hp*61, 0))
	$box_ally/playername.text = playername
	$box_ally/playeratklevel.text = str(playeratk)
	$box_ally/playerdeflevel.text = str(playerdef)
	$box_ally/playerlevel.text = str(playerlvl)
	$box_ally/playerhp.text = (playerhp)
	if playername in special_names:
		$box_ally/Player.play(playername)
	else:
		$box_ally/Player.play("portraits")
		$box_ally/Player.playing = false
		$box_ally/Player.frame = player.character.character_class
	start = OS.get_ticks_msec()
#big code like way too much code
#shrunk code by 50% ;)

func set_entities(player_entity):
	player = player_entity
	playername = player.character.name
	update_stats()
	_ready()

func update_stats():
	playerhp = player.character.hp
	if playerhp < 0:
		playerhp = 0
	playerhp = str(playerhp)  + "/" + str(player.character.max_hp)
	playerlvl = player.character.level
	playeratk = int(round(player.character.atk+ player.character.item_atk.attack))
	playerdef = int(round(player.character.def + player.character.item_def.defense))
	$box_ally/playeratklevel.text = str(playeratk)
	$box_ally/playerdeflevel.text = str(playerdef)
	$box_ally/playerlevel.text = str(playerlvl)
	$box_ally/playerhp.text = (playerhp)

func start_hiding(player):
	var lvl_pos = (player.character.xp)/(player.character.xp_to_next)*28
	$box_ally/levelline.set_point_position(1, Vector2(lvl_pos, 0))
	moving_back = true
	start = OS.get_ticks_msec()
