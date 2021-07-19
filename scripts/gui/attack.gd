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
var hit_chance = 0
var final_damage = 0
export(Array, String) var special_names

var ttl = 100

var bar_size = 133
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
	var hp_amount = clamp((enemy.character.hp - final_damage)/enemy.character.max_hp, 0, 1.0)
	$hp.points[1].x = (hp_amount)*bar_size
	return
	
	if !moving_back:
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
	print("resetting attack UI")
	moving_back = false
	
	$dmgprediction.set_point_position(1, Vector2(enemy.character.hp/enemy.character.max_hp*bar_size, 0))
	
	if player.character.character_class in default_portraits[TT.CONTROL.PLAYER]:
		$PlayerType.play(default_portraits[TT.CONTROL.PLAYER][player.character.character_class])

	if player.character.portrait_override:
		var portrait = player.character.portrait_override
		$portraits.play(portrait)
	else:
		$portraits.play(default_portraits[player.character.control][player.character.character_class])
	
	if enemy.character.portrait_override:
		var portrait = enemy.character.portrait_override
		$portraits2.play(portrait)
	else:
		$portraits2.play(default_portraits[enemy.character.control][enemy.character.character_class])

	$PlayerAdvantage.play("neutral")
	if enemy.character.character_class == player.character.weakness:
		$PlayerAdvantage.play("down")
	elif enemy.character.character_class == player.character.strength:
		$PlayerAdvantage.play("up")
	start = OS.get_ticks_msec()

func set_entities(player_entity, enemy_entity):
	if player_entity.character.control == TT.CONTROL.PLAYER:
		player = player_entity
		enemy = enemy_entity
	else:
		enemy = player_entity
		player = enemy_entity
	update_stats()
	_ready()

func update_stats():
	if enemy and player:
		enemyhp = str(ceil(clamp(enemy.character.hp, 0, 999)))
		enemyhp = enemyhp  + "/" + str(ceil(enemy.character.max_hp))
		hit_chance = str(ceil(clamp(player.character.hit - enemy.character.agi, 0, 100)))
		hit_chance += "%"
		$percentage.text = hit_chance
		final_damage = ceil(get_damage())
		$damage.text = str(enemy.character.hp - final_damage) + '/' + str(enemy.character.max_hp)
		

func get_damage():
	var modifier = 1.0
	if world.mode == world.MODE.SECONDARY_ATTACK:
		if player.character.character_class == TT.TYPE.FIGHTER:
			modifier = 0.6
		if player.character.character_class == TT.TYPE.ARCHER:
			modifier = 0.35
		if player.character.character_class == TT.TYPE.MAGE:
			modifier = 0.45
	var damage = float((player.character.atk + player.character.item_atk.attack) * 3)
	if enemy.character.character_class == player.character.weakness:
		damage = damage * 0.7 * modifier
	if enemy.character.character_class == player.character.strength:
		damage = damage * 1.3 * modifier
	if enemy.guarding:
		damage = damage * 0.65 * modifier
	
	var behind_target = false
	match enemy.movement.last_direction:
		'right':
			if player.tile.x < enemy.tile.x:
				behind_target = true
		'left':
			if player.tile.x > enemy.tile.x:
				behind_target = true
		'up':
			if player.tile.z > enemy.tile.z:
				behind_target = true
		'down':
			if player.tile.z < enemy.tile.z:
				behind_target = true
	if behind_target:
		damage = damage * enemy.behind_dmg_mult
	var target_defense = enemy.character.def + enemy.character.item_def.defense
	var def_multiplier = enemy.get_def_buff(target_defense)
	damage *= def_multiplier
	damage = clamp(floor(damage), 0, 99)
	return damage

func start_hiding(player_entity = null):
	print("moving out Attack UI")
	hide()
	return
	moving_back = true
	start = OS.get_ticks_msec()

func init(target):
	var current_character = world.get_current()
	if current_character == target:
		return
	set_entities(current_character, target)
	show()

func out():
	start_hiding()
