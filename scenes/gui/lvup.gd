extends Control

signal closed

var affectedPlayer: CharacterStats
var stats_diff

func reset():
	$Polygon2D/lv.text = str(affectedPlayer.level-1) + " > " + str(affectedPlayer.level)
	$Polygon2D/hp.text = str(affectedPlayer.max_hp) + " > " + str(affectedPlayer.max_hp + stats_diff.hp)
	$Polygon2D/atk.text = str(affectedPlayer.atk) + " > " + str(affectedPlayer.atk + stats_diff.atk)
	$Polygon2D/def.text = str(affectedPlayer.def) + " > " + str(affectedPlayer.def + stats_diff.def)
	$Polygon2D/hit.text = str(affectedPlayer.hit) + " > " + str(affectedPlayer.hit)
	$Polygon2D/agi.text = str(affectedPlayer.agi) + " > " + str(affectedPlayer.agi)
	$Polygon2D/title.text = affectedPlayer.name + " leveled up"
	$Polygon2D/penta/hb_agi_penta/agi_penta.text = "+" + str(affectedPlayer.bonus_agi)
	$Polygon2D/penta/hb_hit_penta/hit_penta.text = "+" + str(affectedPlayer.bonus_hit)
	$Polygon2D/penta/hb_atk_penta/atk_penta.text = "+" + str(affectedPlayer.bonus_atk)
	$Polygon2D/penta/hb_def_penta/def_penta.text = "+" + str(affectedPlayer.bonus_def)
	$Polygon2D/penta/hb_hp_penta/hp_penta.text = "+" + str(affectedPlayer.bonus_hp)

#func _ready():
#	pass # Replace with function body.

# func init(stats_diff, player):
func init(arg):
	affectedPlayer = arg[1]
	stats_diff = arg[0]
	reset()
	self.visible = true
	$Polygon2D/Abutton/tip2.grab_focus()
	
func out():
	hide()

func _on_tip2_pressed():
	if !visible:
		return
	get_parent().back()
	emit_signal("closed")
	
