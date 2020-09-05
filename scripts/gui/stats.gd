extends Control

var playeratk
var playerdef
var enemyatk
var enemydef
var playerlvl
var playerhp
var playername
var enemylvl
var enemyhp
var enemyname
var player
var enemy

var ttl = 100

var start_x_ally = -30
var end_x_ally = 42

var start_x_enemy = 202
var end_x_enemy = 130

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
		
	if $box_enemy/enemylevelline.get_point_position(1).x > (enemy.character.xp/enemy.character.xp_to_next)*28:
		var new_lvl_pos = Vector2($box_enemy/enemylevelline.get_point_position(1).x - 0.5, 0)
		$box_enemy/enemylevelline.set_point_position(1, new_lvl_pos)
	if $box_enemy/enemylevelline.get_point_position(1).x < (enemy.character.xp/enemy.character.xp_to_next)*28:
		var new_lvl_pos = Vector2($box_enemy/enemylevelline.get_point_position(1).x + 0.5, 0)
		$box_enemy/enemylevelline.set_point_position(1, new_lvl_pos)
		
	#move hp line
	if $box_ally/hpline.get_point_position(1).x > (playerhp/player.character.max_hp)*61:
		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x - 0.5, 0)
		$box_ally/hpline.set_point_position(1, new_hp_pos)
	if $box_ally/hpline.get_point_position(1).x < (playerhp/player.character.max_hp)*61:
		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x + 0.5, 0)
		$box_ally/hpline.set_point_position(1, new_hp_pos)
	
	if $box_enemy/hpline.get_point_position(1).x > (enemyhp/enemy.character.max_hp)*61:
		var new_hp_pos = Vector2($box_enemy/hpline.get_point_position(1).x - 0.5, 0)
		$box_enemy/hpline.set_point_position(1, new_hp_pos)
	if $box_enemy/hpline.get_point_position(1).x < (enemyhp/enemy.character.max_hp)*61:
		var new_hp_pos = Vector2($box_enemy/hpline.get_point_position(1).x + 0.5, 0)
		$box_enemy/hpline.set_point_position(1, new_hp_pos)
	
	if !moving_back:
		update_stats()
		if $box_ally.position.x < end_x_ally:
			$box_ally.position.x = lerp(start_x_ally, end_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = end_x_ally
		if $box_enemy.position.x > end_x_enemy:
			$box_enemy.position.x = lerp(start_x_enemy, end_x_enemy, float(now - start) / float(ttl))
		else:
			$box_enemy.position.x = end_x_enemy
	else:
		if $box_ally.position.x > start_x_ally:
			$box_ally.position.x = lerp(end_x_ally, start_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = start_x_ally
			hide()
		if $box_enemy.position.x < start_x_enemy:
			$box_enemy.position.x = lerp(end_x_enemy, start_x_enemy, float(now - start) / float(ttl))
		else:
			$box_enemy.position.x = start_x_enemy
			hide()

func _ready():
	if not player or not enemy:
		return
	moving_back = false
	$box_enemy/hpline.set_point_position(1, Vector2(enemy.character.hp/enemy.character.max_hp*61, 0))
	$box_ally/hpline.set_point_position(1, Vector2(player.character.hp/player.character.max_hp*61, 0))
	$box_ally/playername.text = playername
	$box_ally/playeratklevel.text = str(playeratk)
	$box_ally/playerdeflevel.text = str(playerdef)
	$box_ally/playerlevel.text = str(playerlvl)
	$box_enemy/enemyname.text = enemyname
	$box_enemy/enemyatklevel.text = str(enemyatk)
	$box_enemy/enemydeflevel.text = str(enemydef)
	$box_enemy/enemylevel.text = str(enemylvl)
	$box_enemy/enemyhp.text = str(enemyhp)
	$box_ally/playerhp.text = str(playerhp)
	$PlayerType.frame = atlas_frames[player.character.character_class]
	$EnemyType.frame = atlas_frames[enemy.character.character_class]
	$box_ally/Player.frame = atlas_frames[player.character.character_class]
	$box_enemy/Enemy.frame = enemy.character.character_class
	print (enemy.character.character_class)
	$PlayerAdvantage.play("neutral")
	$EnemyAdvantage.play("neutral")
	if player.character.character_class == enemy.character.weakness:
		$EnemyAdvantage.play("down")
	elif player.character.character_class == enemy.character.strength:
		$EnemyAdvantage.play("up")
	if enemy.character.character_class == player.character.weakness:
		$PlayerAdvantage.play("down")
	elif enemy.character.character_class == player.character.strength:
		$PlayerAdvantage.play("up")
	start = OS.get_ticks_msec()
#big code like way too much code
#shrunk code by 50% ;)

func set_entities(player_entity, enemy_entity):
	player = player_entity
	enemy = enemy_entity
	playername = player.character.name
	enemyname = enemy.character.name
	if player == enemy:
		$box_enemy.hide()
		$vs.hide()
		$EnemyType.hide()
	else:
		$box_enemy.show()
		$vs.show()
		$EnemyType.show()
	update_stats()
	_ready()

func update_stats():
	playerhp = player.character.hp
	if playerhp < 0:
		playerhp = 0
	playerlvl = player.character.level
	playeratk = floor(player.character.atk+ player.character.item_atk.attack)
	playerdef = floor(player.character.def + player.character.item_def.defense)
	enemyhp = enemy.character.hp
	if enemyhp < 0:
		enemyhp = 0
	enemylvl = enemy.character.level
	enemyatk = floor(enemy.character.atk + enemy.character.item_atk.attack)
	enemydef = floor(enemy.character.def + enemy.character.item_def.defense)
	$box_ally/playeratklevel.text = str(playeratk)
	$box_ally/playerdeflevel.text = str(playerdef)
	$box_ally/playerlevel.text = str(playerlvl)
	$box_enemy/enemyatklevel.text = str(enemyatk)
	$box_enemy/enemydeflevel.text = str(enemydef)
	$box_enemy/enemylevel.text = str(enemylvl)
	$box_enemy/enemyhp.text = str(enemyhp)
	$box_ally/playerhp.text = str(playerhp)

func start_hiding(player):
	var lvl_pos = (player.character.xp)/(player.character.xp_to_next)*28
	$box_ally/levelline.set_point_position(1, Vector2(lvl_pos, 0))
	moving_back = true
	start = OS.get_ticks_msec()
