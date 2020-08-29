extends Control

var player
var enemy

func _ready():
	if not player:
		return
	if player.character_class == Game.TYPE.FIGHTER:
		if enemy.character_class == Game.TYPE.FIGHTER:
			$PlayerType.frame = 32
			$EnemyType.frame = 32
		elif enemy.character_class == Game.TYPE.MAGE:
			$PlayerType.frame = 32
			$EnemyType.frame = 34
		elif enemy.character_class == Game.TYPE.ARCHER:
			$PlayerType.frame = 32
			$EnemyType.frame = 33
	elif player.character_class == Game.TYPE.MAGE:
		if enemy.character_class == Game.TYPE.FIGHTER:
			$PlayerType.frame = 34
			$EnemyType.frame = 32
		elif enemy.character_class == Game.TYPE.MAGE:
			$PlayerType.frame = 34
			$EnemyType.frame = 34
		elif enemy.character_class == Game.TYPE.ARCHER:
			$PlayerType.frame = 34
			$EnemyType.frame = 33
	elif player.character_class == Game.TYPE.ARCHER:
		if enemy.character_class == Game.TYPE.FIGHTER:
			$PlayerType.frame = 33
			$EnemyType.frame = 32
		elif enemy.character_class == Game.TYPE.MAGE:
			$PlayerType.frame = 33	
			$EnemyType.frame = 34
		elif enemy.character_class == Game.TYPE.ARCHER:
			$PlayerType.frame = 33
			$EnemyType.frame = 33

func set_entities(player_character, enemy_character):
	player = player_character
	enemy = enemy_character
	_ready()
	#playerhealth = player.hp
	#playermaxhealth = player.max_hp
	#enemyhealth = enemy.hp
	#enemymaxhealth = enemy.max_hp
	#playertype = player.character_class
	#enemytype = enemy.character_class

func _process(delta):
	if not visible or not player:
		return
	$playerhealthbar.set_value(player.hp, player.max_hp)
	$enemyhealthbar.set_value(enemy.hp, enemy.max_hp)
	$playerhealth.text = "%02d" % clamp(player.hp, 0, player.max_hp)
	$playermaxhealth.text = "%02d" % player.max_hp
	$enemyhealth.text = "%02d" % clamp(enemy.hp, 0, enemy.max_hp)
	$enemymaxhealth.text = "%02d" % enemy.max_hp
