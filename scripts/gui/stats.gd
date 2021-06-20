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
export(Array, String) var special_names

var ttl = 100

var bar_size = 80
var xp_bar_size = 35
var start_x_ally = -160
var end_x_ally = 0

var start_x_enemy = 320
var end_x_enemy = 160

var moving_back = false

var start

onready var world = get_tree().get_root().get_node("World")

var default_portraits = {
	TT.CONTROL.AI: {
		TT.TYPE.ARCHER: "ai_archer",
		TT.TYPE.MAGE: "ai_mage",
		TT.TYPE.FIGHTER: "ai_swordsman",
		TT.TYPE.BOBA: "boba",
		TT.TYPE.POISON_BOBA: "poison_boba"
	},
	TT.CONTROL.PLAYER: {
		TT.TYPE.ARCHER: "archer",
		TT.TYPE.MAGE: "mage",
		TT.TYPE.FIGHTER: "swordsman"
	}
}

func _process(_delta):
	if !visible or !player:
		return
	var now = OS.get_ticks_msec()
	
	
	# KuhnC 9/Apr/21
	# whatever this is doing: no, doing it the fixed way for now.
	$box_ally/levelline.get_point_position(1).x = (player.character.xp/player.character.xp_to_next)*xp_bar_size
	$box_ally/hpline.get_point_position(1).x = (player.character.hp/player.character.max_hp)*bar_size
	$box_enemy/enemylevelline.get_point_position(1).x = (enemy.character.xp/enemy.character.xp_to_next)*xp_bar_size
	$box_enemy/hpline.get_point_position(1).x = (enemy.character.hp/enemy.character.max_hp)*bar_size
	
	# I do get why you'd do *this*, but
	# why not use an animationcontroller for appear/disappear ?
	

#	#move level line to the current exp
#	if $box_ally/levelline.get_point_position(1).x > (player.character.xp/player.character.xp_to_next)*xp_bar_size:
#		var new_lvl_pos = Vector2($box_ally/levelline.get_point_position(1).x - 0.5, 0)
#		$box_ally/levelline.set_point_position(1, new_lvl_pos)
#	if $box_ally/levelline.get_point_position(1).x < (player.character.xp/player.character.xp_to_next)*xp_bar_size:
#		var new_lvl_pos = Vector2($box_ally/levelline.get_point_position(1).x + 0.5, 0)
#		$box_ally/levelline.set_point_position(1, new_lvl_pos)
#		
#	if $box_enemy/enemylevelline.get_point_position(1).x > (enemy.character.xp/enemy.character.xp_to_next)*xp_bar_size:
#		var new_lvl_pos = Vector2($box_enemy/enemylevelline.get_point_position(1).x - 0.5, 0)
#		$box_enemy/enemylevelline.set_point_position(1, new_lvl_pos)
#	if $box_enemy/enemylevelline.get_point_position(1).x < (enemy.character.xp/enemy.character.xp_to_next)*xp_bar_size:
#		var new_lvl_pos = Vector2($box_enemy/enemylevelline.get_point_position(1).x + 0.5, 0)
#		$box_enemy/enemylevelline.set_point_position(1, new_lvl_pos)
#		
#	#move hp line
#	if $box_ally/hpline.get_point_position(1).x > (player.character.hp/player.character.max_hp)*bar_size:
#		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x - 0.5, 0)
#		$box_ally/hpline.set_point_position(1, new_hp_pos)
#	if $box_ally/hpline.get_point_position(1).x < (player.character.hp/player.character.max_hp)*bar_size:
#		var new_hp_pos = Vector2($box_ally/hpline.get_point_position(1).x + 0.5, 0)
#		$box_ally/hpline.set_point_position(1, new_hp_pos)
#	
#	if $box_enemy/hpline.get_point_position(1).x > (enemy.character.hp/enemy.character.max_hp)*bar_size:
#		var new_hp_pos = Vector2($box_enemy/hpline.get_point_position(1).x - 0.5, 0)
#		$box_enemy/hpline.set_point_position(1, new_hp_pos)
#	if $box_enemy/hpline.get_point_position(1).x < (enemy.character.hp/enemy.character.max_hp)*bar_size:
#		var new_hp_pos = Vector2($box_enemy/hpline.get_point_position(1).x + 0.5, 0)
#		$box_enemy/hpline.set_point_position(1, new_hp_pos)
	
	if !moving_back:
		if now - start < ttl:
			$vs.scale = lerp(Vector2(0, 0), Vector2(1, 1), float(now - start) / float(ttl))
		else:
			$vs.scale = Vector2(1, 1)
		#update_stats()
		if $box_ally.position.x < end_x_ally:
			$box_ally.position.x = lerp(start_x_ally, end_x_ally, float(now - start) / float(ttl))
		else:
			$box_ally.position.x = end_x_ally
		if $box_enemy.position.x > end_x_enemy:
			$box_enemy.position.x = lerp(start_x_enemy, end_x_enemy, float(now - start) / float(ttl))
		else:
			$box_enemy.position.x = end_x_enemy
	else:
		if now - start < ttl:
			$vs.scale = lerp(Vector2(1, 1), Vector2(0, 0), float(now - start) / float(ttl))
		else:
			$vs.scale = Vector2(0, 0)
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
	print("resetting battle UI")
	moving_back = false
	$box_enemy/hpline.set_point_position(1, Vector2(enemy.character.hp/enemy.character.max_hp*bar_size, 0))
	$box_ally/hpline.set_point_position(1, Vector2(player.character.hp/player.character.max_hp*bar_size, 0))
	$box_ally/playername.text = playername
	$box_ally/playeratklevel.text = str(playeratk)
	$box_ally/playerdeflevel.text = str(playerdef)
	$box_ally/playerlevel.text = str(playerlvl)
	$box_enemy/enemyname.text = enemyname
	$box_enemy/enemyatklevel.text = str(enemyatk)
	$box_enemy/enemydeflevel.text = str(enemydef)
	$box_enemy/enemylevel.text = str(enemylvl)
	$box_enemy/enemyhp.text = (enemyhp)
	$box_ally/playerhp.text = (playerhp)
	if player.character.character_class in default_portraits[TT.CONTROL.PLAYER]:
		$PlayerType.play(default_portraits[TT.CONTROL.PLAYER][player.character.character_class])
	if enemy.character.character_class in default_portraits[TT.CONTROL.PLAYER]:
		$EnemyType.play(default_portraits[TT.CONTROL.PLAYER][enemy.character.character_class])
		$EnemyType.show()
	else:
		$EnemyType.hide()

	if player.character.portrait_override:
		var portrait = player.character.portrait_override
		$box_ally/portraits.play(portrait)
	else:
		$box_ally/portraits.play(default_portraits[player.character.control][player.character.character_class])
	if enemy.character.portrait_override:
		var portrait = enemy.character.portrait_override
		$box_enemy/portraits.play(portrait)
	else:
		$box_enemy/portraits.play(default_portraits[enemy.character.control][enemy.character.character_class])

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
	if enemy.character.character_class == TT.TYPE.BOBA or enemy.character.character_class == TT.TYPE.POISON_BOBA:
		$EnemyAdvantage.play("boba")
	start = OS.get_ticks_msec()
#big code like way too much code
#shrunk code by 50% ;)

func set_entities(player_entity, enemy_entity):
	if player_entity.character.control == TT.CONTROL.PLAYER:
		player = player_entity
		enemy = enemy_entity
	else:
		enemy = player_entity
		player = enemy_entity
	playername = player.character.name
	enemyname = enemy.character.name
	if player == enemy:
		$box_enemy.hide()
		$vs.hide()
		$EnemyType.hide()
		$PlayerType.hide()
	else:
		$box_enemy.show()
		$vs.show()
		$EnemyType.show()
		$PlayerType.show()
	update_stats()
	_ready()

func update_stats():
	if enemy and player:
		enemyhp = str(ceil(clamp(enemy.character.hp, 0, 999)))
		playerhp = str(ceil(clamp(player.character.hp, 0, 999)))
		enemyhp = enemyhp  + "/" + str(ceil(enemy.character.max_hp))
		playerhp = playerhp  + "/" + str(ceil(player.character.max_hp))
		playerlvl = player.character.level
		playeratk = int(round(player.character.atk + player.character.item_atk.attack))
		playerdef = int(round(player.character.def + player.character.item_def.defense))
		enemylvl = enemy.character.level
		enemyatk = int(round(enemy.character.atk + enemy.character.item_atk.attack))
		enemydef = int(round(enemy.character.def + enemy.character.item_def.defense))
		$box_ally/playeratklevel.text = str(playeratk)
		$box_ally/playerdeflevel.text = str(playerdef)
		$box_ally/playerlevel.text = str(playerlvl)
		$box_enemy/enemyatklevel.text = str(enemyatk)
		$box_enemy/enemydeflevel.text = str(enemydef)
		$box_enemy/enemylevel.text = str(enemylvl)
		$box_enemy/enemyhp.text = enemyhp
		$box_ally/playerhp.text = playerhp

func start_hiding(player_entity = null):
	if player_entity:
		var lvl_pos = (player_entity.character.xp)/(player_entity.character.xp_to_next)*28
		$box_ally/levelline.set_point_position(1, Vector2(lvl_pos, 0))
	print("moving out Battle UI")
	moving_back = true
	start = OS.get_ticks_msec()


func init(target):
	var current_character = world.get_current()
	set_entities(current_character, target)
	show()

func out():
	start_hiding()
