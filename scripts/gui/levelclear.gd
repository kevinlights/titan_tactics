extends Control

signal next
signal retry

func pick_random_sfx(audio_path):
	var effects = audio_path.get_children()
	effects[rand_range(0, effects.size() - 1)].play()

func _ready():
	pass

func reset():
	pick_random_sfx(get_parent().get_node("sfx/turn_alert"))
	$bg.frame = 0
	$bg.play("default")

func _on_Next_pressed():
	emit_signal("next")

func _on_Retry_pressed():
	emit_signal("retry")
