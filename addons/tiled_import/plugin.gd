extends EditorPlugin
tool


var tmx_import_plugin
var world_import_plugin


func _enter_tree():
	tmx_import_plugin = load('res://addons/tiled_import/tmx_import.gd').new()
	add_import_plugin(tmx_import_plugin)
	world_import_plugin = load('res://addons/tiled_import/world_import.gd').new()
	add_import_plugin(world_import_plugin)


func _exit_tree():
	remove_import_plugin(tmx_import_plugin)
	remove_import_plugin(world_import_plugin)


func get_plugin_icon():
	# Non copyright infringing Aseprite icon rip off, not sure what this actually does
	return load("res://addons/tiled_import/icon.png")
