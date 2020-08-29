extends Control

var playeratk
var playerdef
var enemyatk
var enemydef
var player
var enemy

var atlas_frames = {
	"up": 3,
	"down": 2,
	"neutral": 128,
	Game.TYPE.ARCHER: 33,
	Game.TYPE.FIGHTER: 32,
	Game.TYPE.MAGE: 34
}

func _ready():
	if not player or not enemy:
		return
	$playeratklevel.text = str(playeratk)
	$playerdeflevel.text = str(playerdef)
	$enemyatklevel.text = str(enemyatk)
	$enemydeflevel.text = str(enemydef)
	$PlayerType.frame = atlas_frames[player.character.type]
	$EnemyType.frame = atlas_frames[enemy.character.type]
	$PlayerAdvantage.play("neutral")
	$EnemyAdvantage.play("neutral")
	if player.character.type == enemy.character.weakness:
		$EnemyAdvantage.play("down")
	elif player.character.type == enemy.character.strength:
		$EnemyAdvantage.play("up")
	if enemy.character.type == player.character.weakness:
		$PlayerAdvantage.play("down")
	elif enemy.character.type == player.character.strength:
		$PlayerAdvantage.play("up")
#big code like way too much code
#shrunk code by 50% ;)

func set_entities(player_entity, enemy_entity):
	player = player_entity
	enemy = enemy_entity
	playeratk = floor(player.character.attack_damage + player.character.item.attack)
	playerdef = floor(player.character.defense + player.character.item.defense)
	enemyatk = floor(enemy.character.attack_damage + enemy.character.item.attack)
	enemydef = floor(enemy.character.defense + enemy.character.item.defense)
	_ready()
