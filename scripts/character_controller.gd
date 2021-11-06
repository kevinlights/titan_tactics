tool
class_name CharacterController
extends Spatial

signal path_complete
signal idle
signal death
signal recruited
# signal recruit_failed
signal done
signal dialogue
signal attack_complete
signal hit

#---
signal emote_finished
#---

enum AI_STATUS {
	IDLE,
	ALERT,
	HOSTILE
}

var guarding = false
var character
var path = []
var avatar
# var item = Item.new(0, 0, 0) # dummy item, no buffs
var tile = Vector3(0, 0, 0)
onready var last_path = PoolVector3Array([tile])
var is_loot = false
var is_dead = false
var is_trigger = false
var healthbar
var last_target
var is_done = false

var initialized = false

var dialogue
var recruit_dialogue
var death_dialogue

var dialogue_used = false
var status_effects = []

var status = AI_STATUS.IDLE
var behind_dmg_mult = 1.3

var attacker_pos = null

onready var world = get_parent().get_parent().get_parent()

var logger = Logger.new("CharacterController")
var directions = {
	TT.CAMERA.NORTH: {
		"left": "left",
		"right": "right",
		"up": "up",
		"down": "down"
	},
	TT.CAMERA.SOUTH: {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
	},
	TT.CAMERA.EAST: {
		"left": "up",
		"right": "down",
		"up": "right",
		"down": "left"
	},
	TT.CAMERA.WEST: {
		"left": "down",
		"right": "up",
		"up": "left",
		"down": "right"
	}
}

var target_tiles = {
	TT.TYPE.MAGE: [
		Vector3(-1, 0, 0 ),
		Vector3( 1, 0, 0 ),
		Vector3( 0, 0, 1 ),
		Vector3( 0, 0, -1)
	],
	TT.TYPE.ARCHER: [
		Vector3( 0, 0, 0 ),
		Vector3( 1, 0, 1 ),
		Vector3(-1, 0, 1 ),
		Vector3(-1, 0, -1),
		Vector3( 1, 0, -1)
	],
	"sweeping_blow_north": [
		Vector3( -1, 0,  -1),
		Vector3( 0, 0, -1),
		Vector3( 1, 0, -1)
	],
	"sweeping_blow_south": [
		Vector3( -1, 0, 1),
		Vector3( 0, 0, 1),
		Vector3( 1, 0, 1)
	],
	"sweeping_blow_west": [
		Vector3( -1, 0, -1),
		Vector3( -1, 0, 0),
		Vector3( -1, 0, 1)
	],
	"sweeping_blow_east": [
		Vector3( 1, 0, -1),
		Vector3( 1, 0, 0),
		Vector3( 1, 0, 1)
	]
}

var movement = {
	"start_position": Vector3(0, 0, 0),
	"end_position": Vector3(0, 0, 0),
	"start_time": 0,
	"speed": 400 / 3.25,
	"last_direction": "down",
	"moving": false
}

func get_hit_chance():
	# TODO: read/compute hit chance from json stats + lvl upgrades
	return 0.90

func apply_effects(free=false):
	for effect in status_effects:
		if effect.turns_left > 0 or free:
			character.hp -= effect.damage
			if effect.effect == StatusEffect.EFFECT.STUN:
				character.turn_limits.actions = 0
				character.turn_limits.move_actions = 0
				$vfx/stun.show()
				$vfx/stun.play()
				pick_random_sfx($sfx/stun_hit)
			if effect.effect == StatusEffect.EFFECT.POISON:
				$vfx/poison.show()
				$vfx/poison.play()
				pick_random_sfx($sfx/poison_hit)
			if effect.effect == StatusEffect.EFFECT.POLYMORPH:
				$vfx/poison.show()
				$vfx/poison.play()
				pick_random_sfx($sfx/polymorph_hit)
			if not free:
				effect.turns_left -= 1
		else:
			var tag = effect.tag()
			if tag:
				get_node(tag).hide()

	if has_node("healthbar"):
		$healthbar.set_value(character.hp, character.max_hp)

func check_finished():
	if not is_done and character.turn_limits.actions == 0 and character.turn_limits.move_actions == 0:
		is_done = true
		if character.control != TT.CONTROL.AI:
			$done.show()
			emit_signal("done")

func _ready():
	var _ret
	if $emotes.has_signal("animation_finished"):
		_ret = $emotes.connect("animation_finished", self, "_emote_finished")
	else:
		_ret = $emotes.connect("frame_changed", self, "_emote_check_old")
	#pass

func _emote_check_old() -> void:
	if $emotes:
		var frame_count = $emotes.frames.get_frame_count($emotes.animation)
		if $emotes.frame == frame_count - 1:
			_emote_finished()


func _emote_finished() -> void:
	$emotes.stop()
	yield(get_tree().create_timer(1.0), "timeout")
	$emotes.hide()
	self.emit_signal("emote_finished")

func spread_icons():
	pass
#	if $guard.visible and $speak.visible:
#		$guard.translation.x = -4
#		$speak.translation.x = 11
#	else:
#		$guard.translation.x = 0
#		$speak.translation.x = 7

func flameshower(tile):
	pass

func aoe_vfx(name, tile, delay):
	# logger.info("AoE VFX ", name)
	yield(get_tree().create_timer(delay), "timeout")
	$"vfx/Darken screen".show()
	$"vfx/Darken screen/AnimationPlayer".current_animation = "Darken screen"
	var thunder_storm = load("res://scenes/" + name + ".tscn").instance()
#	yield(get_tree().create_timer(1.0), "timeout")
	get_parent().add_child(thunder_storm)
	thunder_storm.translation = tile
	thunder_storm.play()
	$"vfx/Darken screen/AnimationPlayer".play_backwards()
	yield(get_tree().create_timer(2.0), "timeout")
	thunder_storm.queue_free()

func hit(attacker, attacker_translation):
	match(attacker.character_class):
		TT.TYPE.ARCHER:
			if world.mode != world.MODE.SECONDARY_ATTACK:
	#			# logger.info("arrow hit!")
	#			$vfx/arrow_hit.emitting = true
				$vfx/arrow_hit.frame = 0
				$vfx/arrow_hit.show()
				$vfx/arrow_hit.play()
				pick_random_sfx($sfx/arrow_hit)
		TT.TYPE.FIGHTER:
			pick_random_sfx($sfx/sword_hit)
		TT.TYPE.MAGE:
			if world.mode != world.MODE.SECONDARY_ATTACK:
	#			thunderstorm(tile)
				$vfx/magic_hit.frame = 0
				$vfx/magic_hit.show()
				$vfx/magic_hit.play()
				pick_random_sfx($sfx/magic_hit)
		TT.TYPE.BOBA:
			pick_random_sfx($sfx/boba_hit)
		TT.TYPE.POISON_BOBA:
			pick_random_sfx($sfx/poison_hit)
	avatar.play(avatar.animation.replace("idle", "hit"))
	if attacker.item_atk.effect:
		var hit_effect = StatusEffect.new()
		hit_effect.copy(attacker.item_atk.effect)
		status_effects.append(hit_effect)
		var tag = hit_effect.tag()
		if tag:
			get_node(tag).show()
			apply_effects(true)
		else:
			print("No tag for ", hit_effect.effect)
	if (
		world.MODE.SECONDARY_ATTACK and attacker.character_class == TT.TYPE.FIGHTER
	) or (
		!world.MODE.SECONDARY_ATTACK
	):
		attacker_pos = attacker_translation
	else:
		attacker_pos = null
	if guarding:
		pick_random_sfx($sfx/defend)
	if floor(character.hp) <= 0:
		if character.recruit_mode == 2:
			recruit(attacker)
		else:
			die()
			yield(get_tree().create_timer(1.0), "timeout")
			attacker.add_xp(character.level)
	else:
		if dialogue and not dialogue_used:
			dialogue_used = true
			emit_signal("dialogue", dialogue)
#			gui.dialogue(dialogue)
	if character.hp < character.max_hp and not is_dead:
		$healthbar.show()
	if character.control == TT.CONTROL.AI and can_recruit():
		$speak.show()
		spread_icons()
	emit_signal("hit", self)

func pick_random_sfx(audio_path):
	var audioToPick = audio_path
	if "name" in audioToPick:
		audioToPick = audio_path.name
	# logger.info(self.character.name,  " (", self.character.character_class, ") - picking random SFX: ",audioToPick)

	if self.character.name.to_lower() in Game.sfx["tt"]["sfx"]["v"]:
		# logger.info("would call other sfx")
		var availableSnds = []
		if audioToPick.ends_with("_hit"):
			availableSnds = Game.sfx["tt"]["sfx"]["v"][self.character.name.to_lower()]["h"]
		elif audioToPick.ends_with("death"):
			pass # no sound available
		elif audioToPick.ends_with("attack"):
			availableSnds = Game.sfx["tt"]["sfx"]["v"][self.character.name.to_lower()]["at1"]
		elif audioToPick.ends_with("attack2"):
			availableSnds = Game.sfx["tt"]["sfx"]["v"][self.character.name.to_lower()]["at2"]

		if availableSnds.size() <= 0:
			if "name" in audio_path:
				pick_random_sfx_old(audio_path)
			return

		var selected = availableSnds[rand_range(0,availableSnds.size()-1)]
		var astr = AudioStreamPlayer.new()
		astr.stream = selected
		astr.connect("finished", self, "_disposeObject",[astr])
		astr.play()

		self.add_child(astr)
		# logger.info("played audio stream: ",selected)

	elif "name" in audio_path: # fallback
		pick_random_sfx_old(audio_path)

func pick_random_sfx_old(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func _disposeObject(obj):
	if "playing" in obj:
		obj.stop()
	# logger.info("disposing object: ",obj.name)
	obj.queue_free()

func stop_all_sfx(audio_path):
	var effects = audio_path.get_children()
	for effect in effects:
		effect.stop()

func select():
	pick_random_sfx($sfx/selected)

func teleport(x, y, z):
	tile.x = floor(x)
	tile.y = y
	tile.z = floor(z)
	translation.x = floor(x)
	translation.y = y
	translation.z = floor(z)
	# logger.info('teleport', x, y, z)

func heal(target):
	if character.turn_limits.actions < 1 or !target:
		return 0
	character.turn_limits.actions -= 1
	var healed_hp = round((character.atk * 3) * 0.6)
	target.character.hp = clamp(target.character.hp + healed_hp, 0, target.character.max_hp)
	pick_random_sfx($sfx/heal)
	target.get_node("vfx/heal").show()
	target.get_node("vfx/heal").emitting = true
	target.healthbar.set_value(target.character.hp, target.character.max_hp)
	if target.character.control == TT.CONTROL.AI and !target.can_recruit():
		target.get_node("speak").hide()
		spread_icons()
	if target.character.hp == target.character.max_hp:
		target.healthbar.hide()
	check_finished()
	return healed_hp

func guard():
	if character.has_ability(TT.ABILITY.GUARD):
		$guard.show()
		spread_icons()
		character.turn_limits.actions = 0
		character.turn_limits.move_actions = 0
		character.turn_limits.move_distance = 0
		guarding = true
		check_finished()

func end_turn():
	guarding = false
	is_done = false
	character.reset_turn()
	last_path = PoolVector3Array([tile])
	$guard.hide()
	$done.hide()



func can_attack_tile(target):
	# disable item range bonus
	var target_character = world.entity_at(target)
	if world.mode == world.MODE.ATTACK and (!target_character or target_character.is_loot):
		return false
	if world.mode == world.MODE.SECONDARY_ATTACK:
		var targets = get_aoe_targets(target)
		if targets.size() == 0:
			return false
	var atk_range = character.atk_range # + character.item_atk.attack_range
	if target == null:
		# logger.info("No target tile given")
		return false
	var level_target = Vector2(target.x, target.z)
	var level_source = Vector2(translation.x, translation.z)
	var distance = level_target.distance_to(level_source)
	# logger.info(distance, " <= ", atk_range)
	if atk_range == 1:
		return distance <= atk_range
	else:
		return floor(level_target.distance_to(level_source)) <= atk_range

func can_heal(target):
	# disable item range bonus
	var atk_range = character.atk_range # + character.item_atk.attack_range
	if target == null:
		return false
	if target.character.control != character.control:
		return false
	var level_target = Vector2(target.translation.x, target.translation.z)
	var level_source = Vector2(translation.x, translation.z)
	return !(level_target.distance_to(level_source) > atk_range)

func can_attack(target):
	# disable item range bonus
	var atk_range = character.atk_range # + character.item_atk.attack_range
	if target == null:
		return false
	var level_target = Vector2(target.translation.x, target.translation.z)
	var level_source = Vector2(translation.x, translation.z)
	return !(level_target.distance_to(level_source) > atk_range)

func can_move_and_attack(target):
	if target == null:
		return false
	return can_move_and_attack_tile(target.translation)

func can_move_and_attack_tile(t):
	var total_range = character.mov_range + character.atk_range # + character.item_atk.attack_range
	var level_target = Vector2(t.x, t.z)
	var level_source = Vector2(translation.x, translation.z)
	return !(level_target.distance_to(level_source) > total_range)


func get_def_buff(def_value):
	return 1.0 - (log(def_value) / log(10)) * 0.3

# Create formations here, taking angle (if melee) into account.
func get_attack_offsets(attack:int, angle:int)->Array:
	return []

func damage(target):
	var modifier = 1.0
	if world.mode == world.MODE.SECONDARY_ATTACK:
		if character.character_class == TT.TYPE.FIGHTER:
			modifier = 0.6
		if character.character_class == TT.TYPE.ARCHER:
			modifier = 0.35
		if character.character_class == TT.TYPE.MAGE:
			modifier = 0.45
	#	var absolute_atk_range = character.atk_range + character.item_atk.attack_range
	var damage = float((character.atk + character.item_atk.attack) * 3)
	if target.character.character_class == character.weakness:
		damage = damage * 0.7 * modifier
	if target.character.character_class == character.strength:
		damage = damage * 1.3 * modifier
	if target.guarding:
		damage = damage * 0.65 * modifier
	var behind_target = false
	match target.movement.last_direction:
		'right':
			if tile.x < target.tile.x:
				behind_target = true
		'left':
			if tile.x > target.tile.x:
				behind_target = true
		'up':
			if tile.z > target.tile.z:
				behind_target = true
		'down':
			if tile.z < target.tile.z:
				behind_target = true
	if behind_target:
		damage = damage * behind_dmg_mult
		# Froggy :
		# it may be an inappropriate place for crit detection
		target.battle_effect("crit")
	var target_defense = target.character.def + target.character.item_def.defense
	var def_multiplier = get_def_buff(target_defense)
	damage *= def_multiplier
	damage = clamp(floor(damage), 0, 99)
	target.character.hp -= damage
	if target.has_node("healthbar"):
		target.get_node("healthbar").set_value(target.character.hp, target.character.max_hp)
	var damage_feedback:Node = load("res://scenes/damage_feedback.tscn").instance()
	var feedback_position = world.get_node("lookat/camera").unproject_position(target.translation + Vector3(.5, .5, .5))
	damage_feedback.position = feedback_position
	damage_feedback.get_node("damage").text = "-" + str(damage)
	# logger.info('world.add_child(damage_feedback)', damage_feedback)
	world.add_child(damage_feedback)


func get_aoe_targets(tile:Vector3):
	var targets:Array = []
	if character.character_class == TT.TYPE.FIGHTER:
		target_tiles[character.character_class] = target_tiles["sweeping_blow_" + is_facing()]
	for offset in target_tiles[character.character_class]:
		var target = world.entity_at(tile + offset)
		if target and target.is_loot:
			continue
		if target and target.character.control == character.control:
			continue
		if target:
			targets.append(target)
	return targets

# Enoh: can't work with arrows unless a way to feed the hit signal
# to each target exists.
func attack_new(tile:Vector3, AOE:bool, attack_hits):
	# logger.info("[Enoh's Attack] Attack with AoE support")
	if character.turn_limits.actions < 1:
		return
	var delay = 0
	var targets:Array = []
	if AOE:
		targets = get_aoe_targets(tile)
		# Enoh:
		# Use get_attack_offsets instead
		# example: var offsets:Array = get_attack_offsets(blah, blah)
		# for offset in offsets:
		# target = world.entity_at(tile + offset)
		# check for things like player team or whatever.
		if !(character.character_class in target_tiles):
			target_tiles[character.character_class] = [ Vector3.ZERO ]
		if character.character_class == TT.TYPE.FIGHTER:
			target_tiles[character.character_class] = target_tiles["sweeping_blow_" + is_facing()]

		for offset in target_tiles[character.character_class]:
			if character.character_class == TT.TYPE.MAGE:
				aoe_vfx("thunder_storm", tile + offset, delay)
			if character.character_class == TT.TYPE.ARCHER:
				aoe_vfx("flame_shower", tile + offset, delay)
			if character.character_class == TT.TYPE.FIGHTER:
				$"vfx/Sweeping blow".get_node("sweep_" + is_facing()).frame = 0
				$"vfx/Sweeping blow".show()
				avatar.play(avatar.animation.replace("idle", "attack"))
			delay += 0.5
	else:
		var target = world.entity_at(tile)
		if target and target.character.control != character.control:
			targets.append(target)
	if targets.size() == 0:
		return
	character.turn_limits.actions -= 1
	last_target = targets[targets.size()-1]

	# Damage targets
	for t in targets:
		if attack_hits:
			damage(t)
		else:
			print("Attack missed target")
			# TODO/Idea: move target and show 'missed'?
	if not AOE:
		if character.character_class == TT.TYPE.MAGE:
			var projectile = load("res://scenes/projectile.tscn").instance()
			projectile.fire(translation + Vector3(0, 1,  0), tile + Vector3(0, 1, 0))
			for t in targets:
				projectile.connect("hit", t, "hit", [character, translation])
			projectile.connect("hit", self, "attack_complete")
			world.get_node("lookat/camera").track(projectile)
			pick_random_sfx($sfx/magic_attack)
			# logger.info('get_parent().add_child(projectile)', projectile)
			get_parent().add_child(projectile)
		elif character.character_class == TT.TYPE.ARCHER:
			# move this to on animation complete
			pass
		else:
			attack_complete()
			for t in targets:
				t.hit(character, translation)
	else:
		for t in targets:
			t.hit(character, translation)
		attack_complete(delay + 1.0)
	if not AOE or character.character_class == TT.TYPE.FIGHTER:
		if tile.x < translation.x:
			avatar.play("attack-" +  directions[Game.camera_orientation]["left"])
			movement.last_direction = "left"
		if tile.x > translation.x:
			avatar.play("attack-" +  directions[Game.camera_orientation]["right"])
			movement.last_direction = "right"
		if tile.z < translation.z:
			avatar.play("attack-" +  directions[Game.camera_orientation]["up"])
			movement.last_direction = "up"
		if tile.z > translation.z:
			avatar.play("attack-" +  directions[Game.camera_orientation]["down"])
			movement.last_direction = "down"

func attack(target):
	last_target = target
	if character.turn_limits.actions < 1:
		return 0
	character.turn_limits.actions -= 1
#	var absolute_atk_range = character.atk_range + character.item_atk.attack_range
	var damage = float((character.atk + character.item_atk.attack) * 3)
	if target.character.character_class == character.weakness:
		damage = damage * 0.7
	if target.character.character_class == character.strength:
		damage = damage * 1.3
	if target.guarding:
		damage = damage * 0.65
	var behind_target = false
	match target.movement.last_direction:
		'right':
			if tile.x < target.tile.x:
				behind_target = true
		'left':
			if tile.x > target.tile.x:
				behind_target = true
		'up':
			if tile.z > target.tile.z:
				behind_target = true
		'down':
			if tile.z < target.tile.z:
				behind_target = true
	if behind_target:
		damage = damage * behind_dmg_mult
	var target_defense = target.character.def + target.character.item_def.defense
	var def_multiplier = get_def_buff(target_defense)
	damage *= def_multiplier
	damage = clamp(floor(damage), 0, 99)
	target.character.hp -= damage
	if target.has_node("healthbar"):
		target.get_node("healthbar").set_value(target.character.hp, target.character.max_hp)
	var damage_feedback:Node = load("res://scenes/damage_feedback.tscn").instance()
	var feedback_position = world.get_node("lookat/camera").unproject_position(target.translation + Vector3(.5, .5, .5))
	damage_feedback.position = feedback_position
	damage_feedback.get_node("damage").text = "-" + str(damage)
	# logger.info('world.add_child(damage_feedback)', damage_feedback)
	world.add_child(damage_feedback)

	if character.character_class == TT.TYPE.MAGE:
		var projectile = load("res://scenes/projectile.tscn").instance()
		projectile.fire(translation + Vector3(0, 1,  0), target.translation + Vector3(0, 1, 0))
		projectile.connect("hit", target, "hit", [character, translation])
		projectile.connect("hit", self, "attack_complete")
		world.get_node("lookat/camera").track(projectile)
		pick_random_sfx($sfx/magic_attack)
		# logger.info('get_parent().add_child(projectile)', projectile)
		get_parent().add_child(projectile)
	elif character.character_class == TT.TYPE.ARCHER:
		# move this to on animation complete
		pass
	else:
		attack_complete()
		target.hit(character, translation)

	if target.translation.x < translation.x:
		avatar.play("attack-" +  directions[Game.camera_orientation]["left"])
		movement.last_direction = "left"
	if target.translation.x > translation.x:
		avatar.play("attack-" +  directions[Game.camera_orientation]["right"])
		movement.last_direction = "right"
	if target.translation.z < translation.z:
		avatar.play("attack-" +  directions[Game.camera_orientation]["up"])
		movement.last_direction = "up"
	if target.translation.z > translation.z:
		avatar.play("attack-" +  directions[Game.camera_orientation]["down"])
		movement.last_direction = "down"

	pick_random_sfx("attack")
	return damage

func face(direction):
	match direction:
		"west":
			avatar.play("idle-" + directions[Game.camera_orientation]["left"])
			movement.last_direction = "left"
		"east":
			avatar.play("idle-" + directions[Game.camera_orientation]["right"])
			movement.last_direction = "right"
		"north":
			avatar.play("idle-" + directions[Game.camera_orientation]["up"])
			movement.last_direction = "up"
		"south":
			avatar.play("idle-" + directions[Game.camera_orientation]["down"])
			movement.last_direction = "down"

func is_facing():
	if directions[Game.camera_orientation]["left"] in avatar.animation:
		return "west"
	if directions[Game.camera_orientation]["right"] in avatar.animation:
		return "east"
	if directions[Game.camera_orientation]["down"] in avatar.animation:
		return "south"
	return "north"

func emote(emoji):
	$emotes.stop()
	$emotes.frame = 0
	if $emotes.frames.has_animation(emoji):
		$emotes.show()
		$emotes.play(emoji)
	# else:
		# logger.info("Emoji not supported: ", emoji)
	#yield(get_tree().create_timer(2.0), "timeout")
	#$emotes.hide()

func battle_effect(name : String):
	var effect = $battle_effects.get_node(name)
	$battle_effects.rotation.y = world.get_node("lookat").rotation.y - PI/2
	effect.show()
	effect.get_node("AnimationPlayer").play(name)
	effect.get_node("AnimationPlayer").connect("animation_finished", self, "hide_effect")


func hide_effect(name : String):
	$battle_effects.get_node(name).hide()


func attack_complete(delay=1.0):
	last_path = PoolVector3Array([tile])
	yield(get_tree().create_timer(delay), "timeout")
#	# logger.info("attack complete")
	# logger.info("[Character Controller] (" + character.name + ") attack complete")
	emit_signal("idle")
	emit_signal("attack_complete")
	world.check_battle()
	check_finished()



func move(target_path:PoolVector3Array, unlimited=false, instant=false):
	if movement.moving or target_path.size() == 0 or character.turn_limits.move_actions == 0:
		return
	path = world.pathfinder.generate_walking_path(target_path)
	last_path = target_path
	movement.start_time = OS.get_ticks_msec()

#	movement.end_position = Vector3(path[0].x, 0, path[0].z)
	movement.end_position = Vector3(path[0].x, path[0].y, path[0].z)
	movement.start_position = Vector3(translation.x, translation.y, translation.z)
	movement.moving = true
	pick_random_sfx($sfx/walk)
	if not unlimited:
		character.turn_limits.move_distance -= target_path.size()
		character.turn_limits.move_actions = 0

	if instant:
		movement.start_time = 1
		var pathObj = path.pop_back()
		path.clear()
		path.push_back(pathObj)
		movement.start_position = Vector3(pathObj.x, pathObj.y, pathObj.z)
		movement.end_position = Vector3(pathObj.x, pathObj.y, pathObj.z)

		#translation = movement.end_position
		#emit_signal("path_complete")
		#emit_signal("idle")
		##check_finished()
		#movement.moving = false
		_process(0)
		return

func undo_walk():
	if last_path[0] == tile or movement.moving:
		return
	print("Undoing movement: ", last_path)
	character.turn_limits.move_distance += last_path.size()
	character.turn_limits.move_actions = 1
	world.telport_spawn(self, last_path[0].x, last_path[0].z)
	last_path = PoolVector3Array([tile])


#	check_finished()

func select_type():
	$archer.hide()
	$fighter.hide()
	$mage.hide()
	$ai_boba.hide()
	$ai_archer.hide()
	$ai_fighter.hide()
	$ai_mage.hide()

	# cast
	$kris.hide()
	$elyne.hide()
	$arath.hide()
	if avatar:
		avatar.hide()
	if character.control == TT.CONTROL.PLAYER:
		if character.portrait_override and character.portrait_override != "" and has_node(character.portrait_override):
			avatar = get_node(character.portrait_override)
		else:
			match character.character_class:
				TT.TYPE.ARCHER:
#					# logger.info("Select archer")
					avatar = $archer
				TT.TYPE.FIGHTER:
#					# logger.info("Select fighter")
					# logger.info($fighter)
					avatar = $fighter
				TT.TYPE.MAGE:
#					# logger.info("Select mage")
					avatar = $mage
	else:
		# logger.info(character.name, " has ", character.portrait_override)
		if character.portrait_override and character.portrait_override != "" and has_node(character.portrait_override):
			# logger.info("Character portrait ", character.portrait_override)
			avatar = get_node(character.portrait_override)
		else:
			match character.character_class:
				TT.TYPE.ARCHER:
	#				# logger.info("Select ai archer")
					avatar = $ai_archer
				TT.TYPE.FIGHTER:
	#				# logger.info("Select ai fighter")
					avatar = $ai_fighter
				TT.TYPE.MAGE:
	#				# logger.info("Select ai mage")
					avatar = $ai_mage
				TT.TYPE.BOBA:
	#				# logger.info("Select ai boba")
					avatar = $ai_boba
					avatar.offset.y = 0
				TT.TYPE.POISON_BOBA:
	#				# logger.info("Select ai boba")
					avatar = $ai_poison_boba
					avatar.offset.y = 0
	avatar.connect("frame_changed", self, "_on_frame_changed")
	avatar.show()

func _on_frame_changed():
	if avatar:
		var frame_count = avatar.frames.get_frame_count(avatar.animation)
	#	# logger.info("frames ", frame_count, " current ", avatar.frame)
		if avatar.frame == frame_count - 1:
			_on_animation_finished()

func copy_stats(_spawner):
	pass
#	return CharacterStats.new(default_stats, char_type, control)


func from_spawner(character_spawner, surprise = false):
	if surprise:
		$vfx/poly.frame = 0
		$vfx/poly.play()
		$vfx/poly.show()
	character = character_spawner.stats #.duplicate()
	# reset to max hp when deploying
	character.hp = character.max_hp
	if character.character_class == TT.TYPE.BOBA or character.character_class == TT.TYPE.POISON_BOBA:
		character.name = "Boba"
	if character.level == 0:
		character.xp_to_next = 9999
	dialogue = character_spawner.dialogue
	death_dialogue = character_spawner.death_dialogue
	recruit_dialogue = character_spawner.recruit_dialogue
#	if character_spawner.recruit_dialogue and character_spawner.recruit_dialogue.trigger != PT_Dialogue.TRIGGER.DISABLED:
#	recruit_dialogue = character_spawner.recruit_dialogue
	select_type()
	init_common(character_spawner.stats.control)

func _on_dialogue_completed(_result):
	pass

func from_library(team_member):
	character = team_member
	# reset to max hp when deploying
	character.hp = character.max_hp
	character.control = TT.CONTROL.PLAYER
	select_type()
	init_common(team_member.control)

func can_recruit():
	if character.recruit_mode == 0:
		return
	return character.hp <= character.max_hp / 3
#
#func recruit_failed(source):
#	attack(source)
#	$sfx/recruit/fail.play()
#	emit_signal("recruit_failed")

func recruit(source):
	emit_signal("recruited")
	die()
	source.character.add_xp(character.level)
	$sfx/recruit/success.play()

func despawn():
	$healthbar.hide()
	pick_random_sfx($sfx/death)
	$vfx/poly.frame = 0
	$vfx/poly.play()
	$vfx/poly.show()
	avatar.hide()
	$shadow.hide()
	is_dead = true
	yield(get_tree().create_timer(3.0), "timeout")
	hide()
	emit_signal("death", self)


func die():
	if not is_dead:
		is_dead = true
		$healthbar.hide()
		pick_random_sfx($sfx/death)
		avatar.play("hit-" + directions[Game.camera_orientation][movement.last_direction])
		if death_dialogue:
			emit_signal("dialogue", death_dialogue)

func _on_orientation_changed():
#	# logger.info(str(Game.camera_orientation))
#	# logger.info(movement.last_direction, " ", directions[Game.camera_orientation][movement.last_direction])
	avatar.play("idle-" +  directions[Game.camera_orientation][movement.last_direction])

func init_common(control):
	if initialized:
		return
	initialized = true
# warning-ignore:return_value_discarded
	Game.connect("orientation_changed", self, "_on_orientation_changed")
	healthbar = load("res://scenes/healthbar.tscn").instance()
	healthbar.set_value(character.hp, character.max_hp)
	if control == TT.CONTROL.PLAYER:
		healthbar.get_node("level").color = Color(0.023529, 0.352941, 0.709804)
	healthbar.hide()
	# logger.info('add_child(healthbar)', healthbar)
	add_child(healthbar)

func init(char_type, control = TT.CONTROL.PLAYER):
	var default_stats = load("res://resources/class_stats.tres") # [class_map[char_type]]
	character = CharacterStatsOrig.new()
#	character.from_defaults(char_type, control)
#	var class_map = {
#		TT.TYPE.FIGHTER: "swordsman",
#		TT.TYPE.ARCHER: "archer",
#		TT.TYPE.MAGE: "mage"
#	}
	character.generate(default_stats, char_type, control)
	#Character.new(char_type, control)
	select_type()
	init_common(control)

func fire_arrow(target):
	var projectile = load("res://scenes/arrow.tscn").instance()
	projectile.fire(translation + Vector3(0, 1,  0), target.translation + Vector3(0, 1, 0))
	projectile.connect("hit", target, "hit", [character, translation])
	projectile.connect("hit", self, "attack_complete")
	world.get_node("lookat/camera").track(projectile)
	pick_random_sfx($sfx/arrow_attack)
	# logger.info('get_parent().add_child(projectile)', projectile)
	get_parent().add_child(projectile)
	last_target = null

func _on_animation_finished():
	if avatar.animation.begins_with("attack") and character.character_class == TT.TYPE.ARCHER and last_target:
		fire_arrow(last_target)
	if is_dead and avatar.animation.begins_with("hit"):
		emit_signal("death", self)
		$vfx/arrow_hit.hide()
		$healthbar.hide()
		avatar.stop()
	#print("animation_finished for ", character.name, ' [', avatar.animation,']')
	if avatar.animation.begins_with("attack"):
		avatar.play(avatar.animation.replace("attack", "idle"))
	if avatar.animation.begins_with("hit"):
		if attacker_pos != null:
			if attacker_pos.x < translation.x:
				avatar.play("idle-" +  directions[Game.camera_orientation]["left"])
				movement.last_direction = "left"
			if attacker_pos.x > translation.x:
				avatar.play("idle-" +  directions[Game.camera_orientation]["right"])
				movement.last_direction = "right"
			if attacker_pos.z < translation.z:
				avatar.play("idle-" +  directions[Game.camera_orientation]["up"])
				movement.last_direction = "up"
			if attacker_pos.z > translation.z:
				avatar.play("idle-" +  directions[Game.camera_orientation]["down"])
				movement.last_direction = "down"
			attacker_pos = null
		else:
			avatar.play(avatar.animation.replace("hit", "idle"))

func _process(_delta):
	var now = OS.get_ticks_msec()
	_on_frame_changed()
	_emote_check_old()
	if has_node("healthbar") and $healthbar.visible:
		var hp_position = world.get_node("lookat/camera").unproject_position(translation + Vector3(.5, 0, .5))
		$healthbar.position = hp_position
	if not character:
		return
	if avatar.playing and avatar.animation.begins_with("attack"):
		return
	if character.control == TT.CONTROL.PLAYER:
		if is_done:
			$done.show()
		else:
			$done.hide()
	if not path.empty():
		var progress = float(now - movement.start_time) / float(movement.speed)
		if translation.is_equal_approx(movement.end_position) or progress >= 1.0:
			path.remove(0)
			translation = movement.end_position
			tile.x = floor(translation.x)
			tile.z = floor(translation.z)
			if not path.empty():
				movement.end_position = Vector3(path[0].x, path[0].y, path[0].z)
#				movement.end_position = Vector3(path[0].x, 0, path[0].z)
				movement.start_position = Vector3(translation.x, translation.y, translation.z)
				movement.start_time = now
#				# logger.info(movement.end_position)
				var diff = movement.start_position - movement.end_position
				if abs(diff.x) > abs(diff.z):
					if diff.x > 0:
						avatar.play("walk-" + directions[Game.camera_orientation]["left"])
						movement.last_direction = "left"
					else:
						avatar.play("walk-" + directions[Game.camera_orientation]["right"])
						movement.last_direction = "right"
				else:
					if diff.z > 0:
						avatar.play("walk-" + directions[Game.camera_orientation]["up"])
						movement.last_direction = "up"
					else:
						avatar.play("walk-" + directions[Game.camera_orientation]["down"])
						movement.last_direction = "down"
			else:
				avatar.play("idle-" + directions[Game.camera_orientation][movement.last_direction])
				if movement.moving:
					translation = movement.end_position
#					# logger.info("path complete ", translation)
					# logger.info("[Character Controller] (" + character.name + ") path complete")
					emit_signal("path_complete")
					emit_signal("idle")
					if character.control == TT.CONTROL.PLAYER:
						world.gui.start("action_menu", character.character_class)
					else:
						check_finished()
					movement.moving = false
				stop_all_sfx($sfx/walk)
		else:
			translation = lerp(movement.start_position, movement.end_position, progress)


