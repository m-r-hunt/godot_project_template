extends EditorPlugin
tool


var import_plugin


func _enter_tree():
	import_plugin = load('res://addons/tiled_import/tiled_import.gd').new()
	add_import_plugin(import_plugin)


func _exit_tree():
	remove_import_plugin(import_plugin)


func get_plugin_icon():
	# Non copyright infringing Aseprite icon rip off, not sure what this actually does
	return load("res://addons/tiled_import/icon.png")
