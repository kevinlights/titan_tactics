extends Control

var affectedPlayer: CharacterStats

func reset():
	$Polygon2D/lv.text = str(affectedPlayer.level-1) + " > " + str(affectedPlayer.level)
	$Polygon2D/hp.text = str(affectedPlayer.max_hp) + " > " + str(affectedPlayer.max_hp)
	$Polygon2D/atk.text = str(affectedPlayer.atk) + " > " + str(affectedPlayer.atk)
	$Polygon2D/def.text = str(affectedPlayer.def) + " > " + str(affectedPlayer.def)
	$Polygon2D/hit.text = str(affectedPlayer.hit) + " > " + str(affectedPlayer.hit)
	$Polygon2D/agi.text = str(affectedPlayer.agi) + " > " + str(affectedPlayer.agi)
	$Polygon2D/title.text = affectedPlayer.name + " leveled up"
	$Polygon2D/penta/hb_agi_penta/agi_penta.text = "+" + str(affectedPlayer.bonus_agi)
	$Polygon2D/penta/hb_hit_penta/hit_penta.text = "+" + str(affectedPlayer.bonus_hit)
	$Polygon2D/penta/hb_atk_penta/atk_penta.text = "+" + str(affectedPlayer.bonus_atk)
	$Polygon2D/penta/hb_def_penta/def_penta.text = "+" + str(affectedPlayer.bonus_def)
	$Polygon2D/penta/hb_hp_penta/hp_penta.text = "+" + str(affectedPlayer.bonus_hp)

func _ready():
	pass # Replace with function body.

func connect_levelup_signal(stats_diff, player):
	affectedPlayer = player
	reset()
	self.visible = true
