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

var ttl = 60

var start_x_ally = -30
var end_x_ally = 42

var start_x_enemy = 202
var end_x_enemy = 130

var start

var atlas_frames = {
	"up": 3,
	"down": 2,
	"neutral": 128,
	Game.TYPE.ARCHER: 2,
	Game.TYPE.FIGHTER: 0,
	Game.TYPE.MAGE: 4
}

#level width = 28
func _process(delta):
	if !visible:
		return
	var now = OS.get_ticks_msec()
	if $box_ally.position.x < end_x_ally:
		$box_ally.position.x = lerp(start_x_ally, end_x_ally, float(now - start) / float(ttl))
	else:
		$box_ally.position.x = end_x_ally
	if $box_enemy.position.x > end_x_enemy:
		$box_enemy.position.x = lerp(start_x_enemy, end_x_enemy, float(now - start) / float(ttl))
	else:
		$box_enemy.position.x = end_x_enemy

func _ready():
	if not player or not enemy:
		return
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
	playerhp = player.character.hp
	playerlvl = player.character.level
	playeratk = floor(player.character.atk+ player.character.item_atk.attack)
	playerdef = floor(player.character.def + player.character.item_def.defense)
	enemyhp = enemy.character.hp
	enemyname = enemy.character.name
	enemylvl = enemy.character.level
	enemyatk = floor(enemy.character.atk + enemy.character.item_atk.attack)
	enemydef = floor(enemy.character.def + enemy.character.item_def.defense)
	_ready()
