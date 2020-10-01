tool
extends EditorPlugin

#var dock
var import_plugin

func _enter_tree():
#	dock = preload("res://addons/dialogue_tool/dialogue_editor.tscn").instance()
#	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
#	connect("resource_saved", dock.get_node("vbox/dialogues"), "update_tree")
	import_plugin = preload("res://addons/dialogue_tool/dialogue_importer.gd").new()
	add_import_plugin(import_plugin)

func _exit_tree():
	remove_import_plugin(import_plugin)
	import_plugin = null
#	remove_control_from_docks(dock)
#	dock.free()
