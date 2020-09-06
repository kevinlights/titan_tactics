tool
class_name CharacterController
extends Node2D

signal path_complete
signal idle
signal death
signal recruited
signal recruit_failed
signal done
signal dialogue

var cell_size = Game.cell_size
var guarding = false
var character
var path = []
var avatar
# var item = Item.new(0, 0, 0) # dummy item, no buffs
var tile = Vector2(0, 0)
var is_loot = false
var is_dead = false
var is_trigger = false
var healthbar
var last_target
var is_done = false

var dialogue
var recruit_dialogue
var dialogue_used = false

onready var world = get_parent().get_parent().get_parent()

var movement = {
	"start_position": Vector2(0, 0),
	"end_position": Vector2(0, 0),
	"start_time": 0,
	"speed": 400,
	"last_horizontal_direction": "left",
	"moving": false
}

func check_finished():
	if not is_done and character.turn_limits.actions == 0 and character.turn_limits.move_distance == 0:
		is_done = true
		if character.control != Game.CONTROL.AI:
			$done.show()
		emit_signal("done")

func _ready():
	pass

func spread_icons():
	if $guard.visible and $speak.visible:
		$guard.position.x = -4
		$speak.position.x = 11
	else:
		$guard.position.x = 0
		$speak.position.x = 7

func hit(attacker):
	match(attacker.character_class):
		Game.TYPE.ARCHER:
			print("arrow hit!")
			$vfx/arrow_hit.emitting = true
			pick_random_sfx($sfx/arrow_hit)
		Game.TYPE.FIGHTER:
			pick_random_sfx($sfx/sword_hit)
		Game.TYPE.MAGE:
			$vfx/magic_hit.emitting = true
			pick_random_sfx($sfx/magic_hit)
	avatar.play("hit-" + movement.last_horizontal_direction)
	if guarding:
		pick_random_sfx($sfx/defend)
	if character.hp != character.max_hp:
		healthbar.show()
		healthbar.set_value(character.hp, character.max_hp)
	if character.max_hp <= 0:
		print("nooooooooooooooooooooooo it can't be")
	if character.hp <= 0:
		die()
		attacker.add_xp(character.level)
	else:
		if dialogue and dialogue.trigger == Dialogue.TRIGGER.ATTACK and not dialogue_used:
			dialogue_used = true
			print(dialogue.text)
			emit_signal("dialogue", dialogue)
#			gui.dialogue(dialogue)
	if character.control == Game.CONTROL.AI and can_recruit():
		$speak.show()
		spread_icons()

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func stop_all_sfx(audio_path):
	var effects = audio_path.get_children()
	for effect in effects:
		effect.stop()

func select():
	pick_random_sfx($sfx/selected)

func teleport(x, y):
	tile.x = x
	tile.y = y
	position.x = x * cell_size
	position.y = y * cell_size

func heal(target):
	if character.turn_limits.actions < 1:
		return 0
	character.turn_limits.actions -= 1
	var healed_hp = (character.atk * 3) * 0.6
	target.character.hp = clamp(target.character.hp + healed_hp, 0, target.character.max_hp)
	pick_random_sfx($sfx/heal)
	target.healthbar.set_value(target.character.hp, target.character.max_hp)
	if target.character.control == Game.CONTROL.AI and !target.can_recruit():
		target.get_node("speak").hide()
		spread_icons()
	if target.character.hp == target.character.max_hp:
		target.healthbar.hide()
	check_finished()
	return healed_hp

func guard():
	if character.has_ability(Game.ABILITY.GUARD):
		$guard.show()
		spread_icons()
		character.turn_limits.actions = 0
		character.turn_limits.move_distance = 0
		guarding = true
		check_finished()

func end_turn():
	guarding = false
	is_done = false
	character.reset_turn()
	$guard.hide()
	$done.hide()

func can_attack(target):
	var atk_range = character.atk_range + character.item_atk.attack_range
	print(atk_range, " > ", target.tile.distance_to(tile), " : ", !(target.tile.distance_to(tile) > atk_range));
	return !(target.tile.distance_to(tile) > atk_range)

func get_def_buff(def_value):
	print(log(def_value))
	return 1.0 - (log(def_value) / log(10)) * 0.3

func attack(target):
	
	last_target = target
	if character.turn_limits.actions < 1:
		return 0
	character.turn_limits.actions -= 1
	var atk_range = character.atk_range + character.item_atk.attack_range
	var damage = float((character.atk + character.item_atk.attack) * 3)
	if target.character.character_class == character.weakness:
		damage = damage * 0.7
	if target.character.character_class == character.strength:
		damage = damage * 1.3
	if target.guarding:
		damage = damage * 0.65
	print("atk ", damage)
	var target_defense = target.character.def + target.character.item_def.defense
	var def_multiplier = get_def_buff(target_defense) #1.0 - (target_defense + tanh(target_defense)) / 100
	damage *= def_multiplier
	print("def ", target_defense)
	print("def penalty ", (def_multiplier) * 100.0, "%")
	damage = clamp(floor(damage), 0, 99)
	print("actual damage ", damage)
	target.character.hp -= damage

	if character.character_class == Game.TYPE.MAGE:
		var projectile = load("res://scenes/projectile.tscn").instance()
		projectile.fire(position + Vector2(8, 8), target.position + Vector2(8, 8))
		projectile.connect("hit", target, "hit", [character])
		projectile.connect("hit", self, "attack_complete")
		projectile.get_node("sparkle").play("player" if character.control == Game.CONTROL.PLAYER else "ai")
		pick_random_sfx($sfx/magic_attack)
		get_parent().add_child(projectile)
	elif character.character_class == Game.TYPE.ARCHER:
		# move this to on animation complete 
		pass
	else:
		attack_complete()
		target.hit(character)
	if target.position.x < position.x:
		avatar.play("attack-left")
	if target.position.x > position.x:
		avatar.play("attack-right")
	if target.position.y < position.y:
		avatar.play("attack-up")
	if target.position.y > position.y:
		avatar.play("attack-down")
	world.check_battle()
	check_finished()
	return damage

func attack_complete():
	yield(get_tree().create_timer(1.0), "timeout")
	print("attack complete")
	emit_signal("idle")

func move(target_path:PoolVector2Array):
	if movement.moving or target_path.size() == 0:
		return
	path = target_path
	movement.start_time = OS.get_ticks_msec()
	movement.end_position = Vector2(path[0].x, path[0].y)
	movement.start_position = Vector2(position.x, position.y)
	movement.moving = true
	pick_random_sfx($sfx/walk)
	character.turn_limits.move_distance -= path.size()
	check_finished()

func select_type():
	$archer.hide()
	$fighter.hide()
	$mage.hide()
	$ai_archer.hide()
	$ai_fighter.hide()
	$ai_mage.hide()
	if character.control == Game.CONTROL.PLAYER:
		match character.character_class:
			Game.TYPE.ARCHER:
				print("Select archer")
				avatar = $archer
			Game.TYPE.FIGHTER:
				print("Select fighter")
				print($fighter)
				avatar = $fighter
			Game.TYPE.MAGE:
				print("Select mage")
				avatar = $mage
	else:
		match character.character_class:
			Game.TYPE.ARCHER:
				print("Select ai archer")
				avatar = $ai_archer
			Game.TYPE.FIGHTER:
				print("Select ai fighter")
				avatar = $ai_fighter
			Game.TYPE.MAGE:
				print("Select ai mage")
				avatar = $ai_mage
	print("character class ", character.character_class)
	avatar.connect("animation_finished", self, '_on_animation_finished')
	#item = Item.new()
	
	# print("generated item: " + item.name)
	avatar.show()

func copy_stats(spawner):
	pass
#	return CharacterStats.new(default_stats, char_type, control)

	
func from_spawner(character_spawner):
	character = character_spawner.stats #.duplicate()
	# reset to max hp when deploying
	character.hp = character.max_hp
	if character_spawner.dialogue and character_spawner.dialogue.trigger != Dialogue.TRIGGER.DISABLED:
		dialogue = character_spawner.dialogue
		if character.portrait_override and character.portrait_override != "":
			dialogue.portrait = character.portrait_override
		dialogue.connect("completed", self, "_on_dialogue_completed")
	if character_spawner.recruit_dialogue and character_spawner.recruit_dialogue.trigger != Dialogue.TRIGGER.DISABLED:
		recruit_dialogue = character_spawner.recruit_dialogue
	select_type()
	init_common(character_spawner.stats.control)

func _on_dialogue_completed(result):
	pass

func from_library(team_member):
	character = team_member
	# reset to max hp when deploying
	character.hp = character.max_hp
	select_type()
	init_common(team_member.control)

func can_recruit():
	if Game.sudden_death:
		return true 
	else:
		return character.hp <= character.max_hp / 3

func recruit_failed(source):
	attack(source)
	$sfx/recruit/fail.play()
	emit_signal("recruit_failed")
	
func recruit(source):
#	var chance_to_recruit = 0.5
#	check_finished()
#	if randf() < chance_to_recruit:
#		attack(source)
#		emit_signal("recruit_failed")
#		$sfx/recruit/fail.play()
#		return false
#	else:
	emit_signal("recruited")
	die()
	source.character.add_xp(character.level)
	$sfx/recruit/success.play()

func die():
	is_dead = true
	pick_random_sfx($sfx/death)
	avatar.play("hit-" + movement.last_horizontal_direction)

func init_common(control):
	healthbar = load("res://scenes/healthbar.tscn").instance()
	healthbar.position.x = 0
	healthbar.position.y = -5
	healthbar.set_value(character.hp, character.max_hp)
#	if control == Game.CONTROL.PLAYER:
#		healthbar.get_node("level").color = Color(0.023529, 0.352941, 0.709804)
	healthbar.hide()
	add_child(healthbar)
	
func init(char_type, control = Game.CONTROL.PLAYER):	
	var default_stats = load("res://resources/class_stats.tres") # [class_map[char_type]]
	character = CharacterStats.new()
#	character.from_defaults(char_type, control)
#	var class_map = {
#		Game.TYPE.FIGHTER: "swordsman",
#		Game.TYPE.ARCHER: "archer",
#		Game.TYPE.MAGE: "mage"
#	}
	character.generate(default_stats, char_type, control)
	#Character.new(char_type, control)
	select_type()
	init_common(control)

func fire_arrow(target):
		var projectile = load("res://scenes/arrow.tscn").instance()
		projectile.fire(position + Vector2(8, 8), target.position + Vector2(8, 8))
		projectile.connect("hit", target, "hit", [character])
		projectile.connect("hit", self, "attack_complete")
		pick_random_sfx($sfx/arrow_attack)
		get_parent().add_child(projectile)
		last_target = null
	
func _on_animation_finished():
	if avatar.animation.begins_with("attack") and character.character_class == Game.TYPE.ARCHER and last_target:
		fire_arrow(last_target)
	if is_dead and avatar.animation.begins_with("hit"):
		emit_signal("death", self)
		avatar.stop()
	if avatar.animation.begins_with("attack") or avatar.animation.begins_with("hit") :
		if avatar.animation.ends_with("up"):
			avatar.play("idle-left")
		if avatar.animation.ends_with("down"):
			avatar.play("idle-right")
		if avatar.animation.ends_with("left"):
			avatar.play("idle-left")
		if avatar.animation.ends_with("right"):
			avatar.play("idle-right")

func _process(delta):
	var now = OS.get_ticks_msec()
	if not character:
		return
	if avatar.playing and avatar.animation.begins_with("attack"):
		return
	if character.control == Game.CONTROL.PLAYER:
		if is_done:
			$done.show()
		else:
			$done.hide()
	if not path.empty():
		var progress = float(now - movement.start_time) / float(movement.speed)
		if position.is_equal_approx(movement.end_position) or progress >= 1.0:
			path.remove(0)
			position = movement.end_position
			tile.x = round(position.x / cell_size)
			tile.y = round(position.y / cell_size)			
			if not path.empty():
				movement.end_position = Vector2(path[0].x, path[0].y)
				movement.start_position = Vector2(position.x, position.y)
				movement.start_time = now
				var diff = movement.start_position - movement.end_position
				if abs(diff.x) > abs(diff.y):
					if diff.x > 0:
						avatar.play("walk-left")
						movement.last_horizontal_direction = "left"
					else:
						avatar.play("walk-right")
						movement.last_horizontal_direction = "right"
				else:
					if diff.y > 0:
						avatar.play("walk-up")
					else:
						avatar.play("walk-down")
			else:
				avatar.play("idle-" + movement.last_horizontal_direction)
				if movement.moving:
					print("path complete")
					emit_signal("path_complete")
					emit_signal("idle")
					movement.moving = false
				stop_all_sfx($sfx/walk)
		else:
			position = lerp(movement.start_position, movement.end_position, progress)
