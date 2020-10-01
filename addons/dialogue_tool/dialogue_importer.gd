tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func get_importer_name():
	return "dialogue"

func get_visible_name():
	return "Dialogue"

func get_recognized_extensions():
	return [ "dialogue", "dlg" ]

func get_save_extension():
	return "tres"

func get_resource_type():
	return "Dialogue"

func get_option_visibility(option, options):
	return true

func get_preset_count():
	return 0

func get_import_options(preset):
	match preset:
		Presets.DEFAULT:
			return [{
					   "name": "title_prefix",
					   "default_value": "#"
					},
					{
					   "name": "action_prefix",
					   "default_value": ">"
					}]
		_:
			return []

func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = File.new()
	var err = file.open(source_file, File.READ)
	if err != OK:
		return err
	var dialogue = Dialogue.new()
	dialogue.messages = []
	var current_message = DialogueMessage.new()
	var content = file.get_as_text()
	file.close()
	var items = content.split(options.title_prefix)
	for item in items:
		if item != "":
			var message = DialogueMessage.new()
			var lines = item.split("\n")
			message.title = lines[0]
			lines.remove(0)
			print("Title: ", message.title)
			while lines.size() > 0:
				var line = lines[0].lstrip(" ").rstrip(" ")
				lines.remove(0)
				if not line.begins_with(options.action_prefix):
					if line != "":
						message.message += line + "\n"
				else:
					if not message.handled:
						print("Append message ", message.message)
						dialogue.messages.append(message)
						message.handled = true
					var action = DialogueAction.new()
					var action_command = line.substr(1).lstrip(" ").rstrip(" ").split(" ", true, 1)
					print("Action command: ", action_command[0])
					print("Action target: ", action_command[1])
					action.action = action_command[0]
					if action_command.size() > 1:
						action.target = action_command[1]
					print("Append action ", action.action)
					dialogue.messages.append(action)
			if not message.handled:
				print("Append message ", message.message)
				dialogue.messages.append(message)
#	while not file.eof_reached():
#		var line = file.get_line()
#		if line.begins_with(options.title_prefix):
#			if current_message.title:
#				dialogue.messages.append(current_message)
#			var title = line.substr(1)
#			current_message = DialogueMessage.new()
#			current_message.title = title.lstrip(options.action_prefix + " ").rstrip(" ")
#			current_message.message = ""
#		else:
##			if line.lstrip(" ").rstrip(" ") != "":
#			current_message.message += line + "\n"
	var save_file = "%s.%s" % [save_path, get_save_extension()]
	var error = ResourceSaver.save(save_file, dialogue)
	return error
