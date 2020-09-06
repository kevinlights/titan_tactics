extends Label

var text_color = Color(0.219608, 0.596078, 0.454902)
var selected_color = Color(0.917647, 1, 0.866667)

func _ready():
	get_parent().connect("focus_entered", self, "_on_focus")
	get_parent().connect("focus_exited", self, "_on_blur")
	set("custom_colors/font_color", text_color)	

func _on_focus():
	set("custom_colors/font_color", selected_color)

func _on_blur():
	set("custom_colors/font_color", text_color)	
	
