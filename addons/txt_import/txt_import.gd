extends EditorImportPlugin
tool

# Import plugin for Aseprite sprites and animations.
# Imports into scenes containing Sprite and AnimationPlayer with imported data.
# Aseprite files should be exported with JSON file in Horizontal Strip and "Array" format with frame tags.
# Somewhat cribbed from https://github.com/leonkrause/aseprite-import/tree/master/addons/eska.aseprite_importer (MIT License)
# - mainly the import plugin structure and basic import flow. Actual scene construction is totally new and custom for my needs.


func get_importer_name():
	return "Txt File Import"


func get_visible_name():
	return "Txt File"


func get_recognized_extensions():
	return ["txt"]


func get_save_extension():
	return "tres"


func get_resource_type():
	return "Resource"


func get_option_visibility(_option, _options):
	return true


func get_preset_count():
	return 1


func get_preset_name(_preset):
	return "Default"


func get_import_options(_preset):
	var options =  [
	]
	return options


func get_import_order():
	# We need to run *after* the png has been imported as a texture.
	# Higher order = later, so return a high number?
	return 100


func import(src, target_path, import_options, _r_platform_variants, _r_gen_files):
	var txt_path = src
	target_path = target_path + "." + get_save_extension()

	var file = File.new()
	var error

	error = file.open(txt_path, File.READ)
	if error != OK:
		file.close()
		print(str("Failed to open Txt file %s, " % txt_path, "Error: %s" % error))
		return error
		
	var txt = preload("res://addons/txt_import/Txt.cs").new()
	txt.Content = file.get_as_text()
	
	ResourceSaver.save(target_path, txt)

	return OK
