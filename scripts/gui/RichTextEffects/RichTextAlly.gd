tool
extends RichTextEffect
class_name RichTextAlly

var bbcode = "ally"

var ALLY_COLOR = Color(0.141632, 0.464844, 0.141632)

func _process_custom_fx(char_fx):	
	var color = char_fx.env.get("color", char_fx.color)
	char_fx.color = ALLY_COLOR
	return true
