tool
extends RichTextEffect
class_name RichTextEnemy

var bbcode = "enemy"

var ENEMY_COLOR = Color(0.464844, 0.141632, 0.141632)

func _process_custom_fx(char_fx):	
	var color = char_fx.env.get("color", char_fx.color)
	char_fx.color = ENEMY_COLOR
	return true
