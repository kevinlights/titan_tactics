extends Control

signal closed

var affectedPlayer: CharacterStats
var stats_diff

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

var selected = "hp"
var options = [ "hp", "def", "agi", "hit", "atk" ]

func reset():
	affectedPlayer.bonus_hp = 0
	affectedPlayer.bonus_hit = 0
	affectedPlayer.bonus_agi = 0
	affectedPlayer.bonus_def = 0
	affectedPlayer.bonus_atk = 0

	if selected == "hp":
		affectedPlayer.bonus_hp = 1
	if selected == "hit":
		affectedPlayer.bonus_hit = 1
	if selected == "atk":
		affectedPlayer.bonus_atk = 1
	if selected == "def":
		affectedPlayer.bonus_def = 1
	if selected == "agi":
		affectedPlayer.bonus_agi = 1
		
	$Polygon2D/lv.text = str(affectedPlayer.level-1)
	$Polygon2D/lv2.text = str(affectedPlayer.level)
	$Polygon2D/hp.text = str(affectedPlayer.max_hp)
	$Polygon2D/hp2.text = str(affectedPlayer.max_hp + stats_diff.hp + affectedPlayer.bonus_hp)
	$Polygon2D/atk.text = str(affectedPlayer.atk)
	$Polygon2D/atk2.text = str(affectedPlayer.atk + stats_diff.atk + affectedPlayer.bonus_atk)
	$Polygon2D/def.text = str(affectedPlayer.def)
	$Polygon2D/def2.text = str(affectedPlayer.def + stats_diff.def + affectedPlayer.bonus_def)
	$Polygon2D/hit.text = str(affectedPlayer.hit) + "%"
	$Polygon2D/hit2.text = str(affectedPlayer.hit + affectedPlayer.bonus_hit) + "%"
	$Polygon2D/agi.text = str(affectedPlayer.agi) + "%"
	$Polygon2D/agi2.text = str(affectedPlayer.agi + affectedPlayer.bonus_agi) + "%"
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
	$Polygon2D/portrait/portraits.animation = affectedPlayer.portrait_override
	if affectedPlayer.portrait_override:
		var portrait = affectedPlayer.portrait_override
		$Polygon2D/portrait/portraits.play(portrait)
	else:
		$Polygon2D/portrait/portraits.play(default_portraits[affectedPlayer.control][affectedPlayer.character_class])	
	$Polygon2D/Abutton/tip2.grab_focus()
	
func out():
	hide()

func _on_tip2_pressed():
	if !visible:
		return
	get_parent().back()
	emit_signal("closed")
	
func node_for_stat(stat):
	var node = $Polygon2D/penta.get_node("hb_" + stat + "_penta")
	return node
 
func _input(event):
	if !visible:
		return
	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
		node_for_stat(selected).get_node("focus").hide()
		var idx = options.find(selected)
		if idx == options.size() - 1:
			selected = options[0]
		else:
			selected = options[idx + 1]
		node_for_stat(selected).get_node("focus").show()
		reset()
	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
		node_for_stat(selected).get_node("focus").hide()
		var idx = options.find(selected)
		if idx == 0:
			selected = options[options.size() - 1]
		else:
			selected = options[idx - 1]
		node_for_stat(selected).get_node("focus").show()
		reset()
	if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
		affectedPlayer.hp += affectedPlayer.bonus_hp
		affectedPlayer.agi += affectedPlayer.bonus_agi
		affectedPlayer.def += affectedPlayer.bonus_def
		affectedPlayer.hit += affectedPlayer.bonus_hit
		affectedPlayer.atk += affectedPlayer.bonus_atk
		_on_tip2_pressed()

