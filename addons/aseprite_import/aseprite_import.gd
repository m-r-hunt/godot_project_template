extends EditorImportPlugin
tool

# Import plugin for Aseprite sprites and animations.
# Imports into scenes containing Sprite and AnimationPlayer with imported data.
# Aseprite files should be exported with JSON file in Horizontal Strip and "Array" format with frame tags.
# Somewhat cribbed from https://github.com/leonkrause/aseprite-import/tree/master/addons/eska.aseprite_importer (MIT License)
# - mainly the import plugin structure and basic import flow. Actual scene construction is totally new and custom for my needs.


func get_importer_name():
	return "Aseprite Import"


func get_visible_name():
	return "Aseprite Animated Sprite"


func get_recognized_extensions():
	return ["json"]


func get_save_extension():
	return "scn"


func get_resource_type():
	return "PackedScene"


func get_option_visibility(_option, _options):
	return true


func get_preset_count():
	return 1


func get_preset_name(_preset):
	return "Default"


func get_import_options(_preset):
	var options =  [
		{
			name = "autoplay_animation",
			default_value = "",
		},
		{
			name = "constant_frame_rate",
			default_value = 100,
		},
		{
			name = "default_animation_looping",
			default_value = true,
		},
	]
	return options


func get_import_order():
	# We need to run *after* the png has been imported as a texture.
	# Higher order = later, so return a high number?
	return 100


func import(src, target_path, import_options, _r_platform_variants, _r_gen_files):
	var json_path = src
	target_path = target_path + "." + get_save_extension()

	var file = File.new()
	var error

	error = file.open(json_path, File.READ)
	if error != OK:
		file.close()
		print(str("Failed to open JSON file %s, " % json_path, "Error: %s" % error))
		return error

	var json_result = JSON.parse(file.get_as_text())
	var json = json_result.result
	error = json_result.error
	file.close()

	if error != OK:
		print(str("Error parsing json file %s, " % json_path, "Error: %s" % error))
		return error

	var texture_path = json_path.get_basename() + ".png"

	if not file.file_exists( texture_path ):
		print("Cannot find texture file %s" % texture_path)
		return ERR_FILE_NOT_FOUND
	var texture = load(texture_path)
	if not typeof(texture) == TYPE_OBJECT or not texture is Texture:
		print("Texture file %s is not a texture" % texture_path)
		return ERR_INVALID_DATA

	var sprite = Sprite.new()
	sprite.name = "AsepriteSprite"
	sprite.texture = texture
	sprite.hframes = json.frames.size()

	var animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	sprite.add_child(animation_player)
	animation_player.owner = sprite

	var animations = {}
	for anim in json.meta.frameTags:
		animations[anim.name] = [anim.from, anim.to]
	for key in animations:
		var anim_data = animations[key]
		var anim = Animation.new()
		anim.set_loop(import_options.default_animation_looping)
		var track_index = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track_index, ".:frame")
		for i in range(0, anim_data[1] - anim_data[0]+1):
			anim.track_insert_key(track_index, i*import_options.constant_frame_rate / 1000.0, anim_data[0]+i)
		anim.set_length((anim_data[1]-anim_data[0] + 1)*import_options.constant_frame_rate / 1000.0)
		anim.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
		animation_player.add_animation(key, anim)

	if import_options.autoplay_animation != "":
		animation_player.autoplay = import_options.autoplay_animation

	var packed_scene = PackedScene.new()
	packed_scene.pack(sprite)

	error = ResourceSaver.save(target_path, packed_scene)
	if error != OK:
		print(str("Failed to save packed scene at %s, " % target_path, "Error: %s" % error))
		return ERR_INVALID_PARAMETER

	return OK
