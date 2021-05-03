extends EditorImportPlugin
tool

func get_importer_name():
	return "Tiled World Import"


func get_visible_name():
	return "Tiled World"


func get_recognized_extensions():
	return ["tiled_world"]


func get_save_extension():
	return "res"


func get_resource_type():
	return "Resource"


func get_option_visibility(_option, _options):
	return true


func get_preset_count():
	return 1


func get_preset_name(_preset):
	return "Default"


func get_import_options(_preset):
	var options = [
	]
	return options


func get_import_order():
	return 105


func import(src, target_path, import_options, _r_platform_variants, _r_gen_files):
	var world_path = src
	var world_dir = src.get_base_dir()
	target_path = target_path + "." + get_save_extension()

	var file = File.new()
	var error

	error = file.open(world_path, File.READ)
	if error != OK:
		print(str("Failed to open World file %s, " % world_path, "Error: %s" % error))
		return error

	var world_json = file.get_as_text()
	file.close()

	var result = JSON.parse(world_json)
	if result.error != OK:
		print(str("Failed to parse World json %s, " % world_path, "Error: %s" % result.error))
		return result.error
	
	var mapDesc = load("res://addons/tiled_import/MapDescriptor.cs")
	var maps = result.result["maps"]
	var mapDescs = []
	for m in maps:
		var desc = mapDesc.new()
		desc.X = int(m["x"])
		desc.Y = int(m["y"])
		desc.Width = int(m["width"])
		desc.Height = int(m["height"])
		desc.MapPath = world_dir + "/" + m["fileName"]
		print(desc.MapPath)
		mapDescs.append(desc)

	var res = load("res://addons/tiled_import/TiledWorld.cs").new()
	res.Maps = mapDescs
	
	error = ResourceSaver.save(target_path, res)
	if error != OK:
		print(str("Failed to save world resource at %s, " % target_path, "Error: %s" % error))
		return ERR_INVALID_PARAMETER

	return OK
