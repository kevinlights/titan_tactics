extends Control

signal closed

var affectedPlayer: CharacterStats
var stats_diff

onready var pentapoly = $Polygon2D/penta
onready var initial_shape = PoolVector2Array()

var bonus_hp = 0
var bonus_hit = 0
var bonus_agi = 0
var bonus_def = 0
var bonus_atk = 0

var pentanormals = [
	Vector2(0, -5),
	Vector2(-5, -5),
	Vector2(-5, 5),
	Vector2(5, 5),
	Vector2(5, -5)
]

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
var paths = {
	"atk": {
		"ui_right": "hp",
		"ui_up": "hp",
		"ui_down": "hit"
	},
	"hp": {
		"ui_left": "atk",
		"ui_down": "atk",
		"ui_right": "def"
	},
	"def": {
		"ui_down": "agi",
		"ui_up": "hp",
		"ui_left": "hp"
	},
	"agi": {
		"ui_left": "hit",
		"ui_up": "def"
	},
	"hit": {
		"ui_up": "atk",
		"ui_right": "agi"
	}
}
var max_polygon

func _ready():
	if !affectedPlayer:
		affectedPlayer = CharacterStats.new()
		stats_diff = affectedPlayer
		reset()

func reset():
	bonus_hp = 0
	bonus_hit = 0
	bonus_agi = 0
	bonus_def = 0
	bonus_atk = 0

	if selected == "hp":
		bonus_hp = 1
	if selected == "hit":
		bonus_hit = 1
	if selected == "atk":
		bonus_atk = 1
	if selected == "def":
		bonus_def = 1
	if selected == "agi":
		bonus_agi = 1
	var values = [ 
		bonus_hp,
		bonus_atk,
		bonus_hit,
		bonus_agi,
		bonus_def
	]
	var big = values.max()
	
	if initial_shape.empty():
		initial_shape = PoolVector2Array(pentapoly.polygon)
	
	for i in range(0, 5):
		$Polygon2D/penta.polygon[i] = (initial_shape[i] / 2).linear_interpolate(initial_shape[i], float(values[i]) / float(big))

	$Polygon2D/lv.text = str(affectedPlayer.level-1)
	$Polygon2D/lv2.text = str(affectedPlayer.level)
	$Polygon2D/hp.text = str(affectedPlayer.max_hp)
	$Polygon2D/hp2.text = str(affectedPlayer.max_hp + stats_diff.hp + affectedPlayer.bonus_hp + bonus_hp)
	$Polygon2D/atk.text = str(affectedPlayer.atk)
	$Polygon2D/atk2.text = str(affectedPlayer.atk + stats_diff.atk + affectedPlayer.bonus_atk + bonus_atk)
	$Polygon2D/def.text = str(affectedPlayer.def)
	$Polygon2D/def2.text = str(affectedPlayer.def + stats_diff.def + affectedPlayer.bonus_def + bonus_def)
	$Polygon2D/hit.text = str(affectedPlayer.hit) + "%"
	$Polygon2D/hit2.text = str(affectedPlayer.hit + affectedPlayer.bonus_hit + bonus_hit) + "%"
	$Polygon2D/agi.text = str(affectedPlayer.agi) + "%"
	$Polygon2D/agi2.text = str(affectedPlayer.agi + affectedPlayer.bonus_agi + bonus_agi) + "%"
	$Polygon2D/title.text = affectedPlayer.name + " leveled up"
	$Polygon2D/penta/hb_agi_penta/agi_penta.text = "+" + str(bonus_agi)
	$Polygon2D/penta/hb_hit_penta/hit_penta.text = "+" + str(bonus_hit)
	$Polygon2D/penta/hb_atk_penta/atk_penta.text = "+" + str(bonus_atk)
	$Polygon2D/penta/hb_def_penta/def_penta.text = "+" + str(bonus_def)
	$Polygon2D/penta/hb_hp_penta/hp_penta.text = "+" + str(bonus_hp)
	
	var selected_color = Color(0.9647058823529412, 0.9647058823529412, 0.9568627450980393)
	var unselected_color = Color(0.596078431372549, 0.6196078431372549, 0.611764705882353)
	for opt in options:
		node_for_stat(opt).modulate = selected_color if opt == selected else unselected_color
#
#func _ready():
#	nrmlz()
#	pass # Replace with function body.
#
#func nrmlz():
#	var pent = $Polygon2D/penta2
#	max_polygon = PoolVector2Array(pent.polygon)
#
# func init(stats_diff, player):
func init(arg):
	initial_shape = PoolVector2Array(pentapoly.polygon)
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
	for key in paths[selected]:
		print(key)
		if event.is_action(key) && !event.is_echo() && event.is_pressed():
			selected = paths[selected][key]
			node_for_stat(selected).get_node("focus").show()
			reset()

#	if event.is_action("ui_right") && !event.is_echo() && event.is_pressed():
#		node_for_stat(selected).get_node("focus").hide()
#		var idx = options.find(selected)
#		if idx == options.size() - 1:
#			selected = options[0]
#		else:
#			selected = options[idx + 1]
#		node_for_stat(selected).get_node("focus").show()
#		reset()
#	if event.is_action("ui_left") && !event.is_echo() && event.is_pressed():
#		node_for_stat(selected).get_node("focus").hide()
#		var idx = options.find(selected)
#		if idx == 0:
#			selected = options[options.size() - 1]
#		else:
#			selected = options[idx - 1]
#		node_for_stat(selected).get_node("focus").show()
#		reset()
	if event.is_action("context_action") && !event.is_echo() && event.is_pressed():
		affectedPlayer.bonus_hp += bonus_hp
		affectedPlayer.bonus_agi += bonus_agi
		affectedPlayer.bonus_def += bonus_def
		affectedPlayer.bonus_hit += bonus_hit
		affectedPlayer.bonus_atk += bonus_atk
		_on_tip2_pressed()

