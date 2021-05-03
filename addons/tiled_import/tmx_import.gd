extends EditorImportPlugin
tool

# Import plugin for Aseprite sprites and animations.
# Imports into scenes containing Sprite and AnimationPlayer with imported data.
# Aseprite files should be exported with JSON file in Horizontal Strip and "Array" format with frame tags.
# Somewhat cribbed from https://github.com/leonkrause/aseprite-import/tree/master/addons/eska.aseprite_importer (MIT License)
# - mainly the import plugin structure and basic import flow. Actual scene construction is totally new and custom for my needs.

# Possible improvements:
#  Parse Tiled tile collision data into Godot TileSet collision shapes
#  Pass tile custom properties into custom layer functions
#  Pass object custom properties into scene construction somehow

func get_importer_name():
	return "Tiled Import"


func get_visible_name():
	return "Tiled Map"


func get_recognized_extensions():
	return ["tmx"]


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
	var options = [
		# On Object layers, objects will be loaded from the path object_folder + Tiled object type + ".tscn"
		{"name": "object_folder", "default_value": "res://scenes/objects/"},
		
		# Dictionary mapping layer name to script path (string) used to load that layer.
		# Given script should have a function:
		# static func run(_tiled_layer, _tileset, _tilewidth, _tileheight, root_node):
		# This should process layer data (given via _tiled_layer) and insert a node as a child of/owned by the given root_node
		# The intent is to allow "tile object" layers - painted as tile layers but loaded into nodes via custom logic
		{"name": "custom_layers", "default_value": {}},
	]
	return options


func get_import_order():
	# We need to run *after* the png has been imported as a texture.
	# Higher order = later, so return a high number?
	return 101


func import(src, target_path, import_options, _r_platform_variants, _r_gen_files):
	var tmx_path = src
	var tmx_dir = src.get_base_dir()
	target_path = target_path + "." + get_save_extension()

	var parser = XMLParser.new()
	var error

	error = parser.open(tmx_path)
	if error != OK:
		print(str("Failed to open TMX file %s, " % tmx_path, "Error: %s" % error))
		return error

	# We use an empty dummy TileMap as root/container.
	# This means that the scene appears as a TileMap in the tree.
	# Also the attached script can forward properties to its children.
	var root_node = load("res://addons/tiled_import/TiledMap.cs").new()
	root_node.name = "TiledMap"
	
	error = parser.read()
	if error != OK:
		print(str("Error reading TMX XML in file %s, " % tmx_path, "Error: %s" % error))
		return error

	assert(parser.get_node_type() == XMLParser.NODE_UNKNOWN) # Unknown node at beginning of file
	
	error = parser.read()
	if error != OK:
		print(str("Error reading TMX XML in file %s, " % tmx_path, "Error: %s" % error))
		return error
	assert(parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "map")
	var map_attributes = get_attribute_dict(parser)
	
	error = parser.read()
	if error != OK:
		print(str("Error reading TMX XML in file %s, " % tmx_path, "Error: %s" % error))
		return error
	assert(parser.get_node_type() == XMLParser.NODE_TEXT)

	var tilesets = []
	var layers = []
	var object_groups = []
	var properties = Dictionary()
	while true:
		error = parser.read()
		if error == ERR_FILE_EOF:
			break
		elif error != OK:
			print(str("Error reading TMX XML in file %s, " % tmx_path, "Error: %s" % error))
			return error
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				match parser.get_node_name():
					"tileset":
						var dict = get_attribute_dict(parser)
						var firstgid = int(dict["firstgid"])
						var source = dict["source"]
						var tileset = parse_tileset(firstgid, source, tmx_dir)
						if !tileset:
							return ERR_INVALID_DATA
						tilesets.append(tileset)
					"layer":
						var attributes = get_attribute_dict(parser)
						var layer = parse_layer(parser, tmx_dir, attributes)
						layers.append(layer)
					"objectgroup":
						var attributes = get_attribute_dict(parser)
						var data = parse_object_group(parser, tmx_dir)
						object_groups.append(TiledObjectGroup.new(attributes["name"], data))
					"properties":
						var props = parse_properties_node(parser, tmx_dir)
						properties = props
					_:
						if !parser.is_empty():
							# Unknown node type, just skip contentsb
							error = parser.read()
							assert(parser.get_node_type() == XMLParser.NODE_TEXT)
			XMLParser.NODE_ELEMENT_END:
				pass
			_:
				assert("Unexpected node type")
				
	root_node.Properties = properties
	var tile_props = Dictionary()

	var tileset = TileSet.new()
	tileset.create_tile(0)
	for ts in tilesets:
		ts.add_to_godot_tileset(tileset)
		ts.add_to_tile_props_dict(tile_props)
	
	root_node.TileProperties = tile_props
	
	var custom_layers = import_options["custom_layers"]
	for layer in layers:
		if layer.name in custom_layers:
			var script = load(custom_layers[layer.name])
			script.run(layer, tileset, int(map_attributes["tilewidth"]), int(map_attributes["tileheight"]), root_node)
		else:
			var map = layer.make_godot_tilemap(tileset, int(map_attributes["tilewidth"]), int(map_attributes["tileheight"]), tile_props)
			root_node.add_child(map)
			map.owner = root_node
	
	for group in object_groups:
		group.make_godot_node(root_node, import_options["object_folder"])

	var packed_scene = PackedScene.new()
	packed_scene.pack(root_node)

	error = ResourceSaver.save(target_path, packed_scene)
	if error != OK:
		print(str("Failed to save packed scene at %s, " % target_path, "Error: %s" % error))
		return ERR_INVALID_PARAMETER
		
	root_node.queue_free()

	return OK


func get_attribute_dict(parser: XMLParser):
	var out = {}
	for i in range(0, parser.get_attribute_count()):
		out[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
	return out


class TiledSet:
	var firstgid: int
	var tile_count: int
	var image_source: String
	var tiles: Dictionary
	var columns: int
	var tile_width: int
	var tile_height: int


	func _init(_firstgid: int, _tile_count: int, _image_source: String, _tiles: Dictionary, _columns: int, _tile_width: int, _tile_height: int):
		firstgid = _firstgid
		tile_count = _tile_count
		image_source = _image_source
		tiles = _tiles
		columns = _columns
		tile_width = _tile_width
		tile_height = _tile_height

	func add_to_tile_props_dict(tile_props: Dictionary):
		for i in range(0, tile_count):
			var tid = i + firstgid
			if i in tiles:
				tile_props[tid] = tiles[i].properties

	func add_to_godot_tileset(ts: TileSet):
		var tx = load(image_source)
		for i in range(0, tile_count):
			var tid = i + firstgid
			ts.create_tile(tid)
			ts.tile_set_texture(tid, tx)
			ts.tile_set_region(tid, Rect2((i % columns) * tile_width, (i / columns) * tile_height, tile_width, tile_height))
			if tiles.has(i):
				if "collision" in tiles[i].properties and tiles[i].properties["collision"] == "true":
					var shape = RectangleShape2D.new()
					shape.extents = Vector2(tile_width / 2, tile_height / 2)
					ts.tile_add_shape(tid, shape, Transform2D(0, Vector2(tile_width / 2, tile_height / 2)))
				for obj in tiles[i].objects:
					var shape = RectangleShape2D.new()
					var half_width = float(obj["width"])/2
					var half_height = float(obj["height"])/2
					shape.extents = Vector2(half_width, half_height)
					ts.tile_add_shape(tid, shape, Transform2D(0, Vector2(float(obj["x"]) + half_width, float(obj["y"]) + half_height)))


func parse_tileset(firstgid: int, source: String, base_dir: String):
	var tsx_path = base_dir + "/" + source
	var parser = XMLParser.new()
	var error

	error = parser.open(tsx_path)
	if error != OK:
		print(str("Failed to open TSX file %s, " % tsx_path, "Error: %s" % error))
		return null
	
	error = parser.read()
	error = parser.read()
	if error != OK:
		print(str("Error reading TSX XML in file %s, " % tsx_path, "Error: %s" % error))
		return error
	assert(parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "tileset")
	var tileset_attributes = get_attribute_dict(parser)

	var image_source = null
	var tiles = {}
	while true:
		error = parser.read()
		if error == ERR_FILE_EOF:
			break
		elif error != OK:
			print(str("Error reading TSX XML in file %s, " % tsx_path, "Error: %s" % error))
			return error
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				match parser.get_node_name():
					"image":
						var dict = get_attribute_dict(parser)
						image_source = base_dir + "/" + dict["source"]
					"tile":
						var dict = get_attribute_dict(parser)
						if !parser.is_empty():
							var tile_props = parse_tile(parser, base_dir)
							tiles[int(dict["id"])] = tile_props
					_:
						if !parser.is_empty():
							# Unknown node type, just skip contentsb
							error = parser.read()
							assert(parser.get_node_type() == XMLParser.NODE_TEXT)
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "tileset":
					break
			_:
				assert("Unexpected node type")
	assert(image_source != null)

	return TiledSet.new(
		firstgid, 
		int(tileset_attributes["tilecount"]), 
		image_source, 
		tiles, 
		int(tileset_attributes["columns"]), 
		int(tileset_attributes["tilewidth"]), 
		int(tileset_attributes["tileheight"])
	)

class TiledTile:
	var properties: Dictionary
	var objects: Array
	
	func _init(_properties: Dictionary, _objects: Array):
		properties = _properties
		objects = _objects

func parse_tile(parser: XMLParser, base_path: String):
	var tile_properties = {}
	var objects = []
	while true:
		parser.read()
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				match parser.get_node_name():
					"properties":
						tile_properties = parse_properties_node(parser, base_path)
					"objectgroup":
						objects = parse_object_group(parser, base_path)
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "tile":
					break
	return TiledTile.new(tile_properties, objects)


func parse_properties_node(parser: XMLParser, base_path: String):
	var properties = {}
	while true:
		parser.read()
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				assert(parser.get_node_name() == "property")
				var attributes = get_attribute_dict(parser)
				var value = attributes["value"]
				if "type" in attributes:
					# Default is just string, can be unspecified
					match attributes["type"]:
						"string":
							pass
						"int":
							value = int(value)
						"float":
							value = float(value)
						"bool":
							value = (value == "true")
						"color":
							value = Color(value)
						"file":
							value = load(base_path + "/" + value)
						# TODO "object" - store object refs, after initializing scene, fixup into node references
				properties[attributes["name"]] = value
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "properties":
					break
	return properties


func parse_layer(parser: XMLParser, base_path: String, attributes: Dictionary):
	var layer_data = null
	var props = Dictionary()
	while true:
		parser.read()
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				match parser.get_node_name():
					"data":
						var data_attributes = get_attribute_dict(parser)
						assert(data_attributes["encoding"] == "csv")
						parser.read()
						assert(parser.get_node_type() == XMLParser.NODE_TEXT)
						layer_data = parser.get_node_data()
					"properties":
						props = parse_properties_node(parser, base_path)
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "layer":
					break
	return TiledLayer.new(attributes["name"], layer_data, int(attributes["width"]), int(attributes["height"]), props)


func parse_object_group(parser: XMLParser, base_path: String):
	var objects = []
	if parser.is_empty():
		return objects
	while true:
		parser.read()
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				match parser.get_node_name():
					"object":
						var attributes = get_attribute_dict(parser)
						objects.append(attributes)
					"properties":
						assert(len(objects) > 0)
						var properties = parse_properties_node(parser, base_path)
						objects.back()["properties"] = properties
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "objectgroup":
					break
	return objects


class TiledObjectGroup:
	var name: String
	var objects: Array


	func _init(_name: String, _objects: Array):
		name = _name
		objects = _objects


	func make_godot_node(owner: Node, folder: String):
		var node = load("res://addons/tiled_import/TiledObjectLayer.cs").new()
		node.name = name
		owner.add_child(node)
		node.owner = owner
		for object in objects:
			var object_scene = load(folder + object["type"] + ".tscn")
			var instance = object_scene.instance()
			if "properties" in object:
				for k in object["properties"]:
					instance.set(k, object["properties"][k])
			node.add_child(instance)
			instance.name = object["name"]
			instance.owner = owner
			instance.position = Vector2(int(object["x"]), int(object["y"]))
		return node


class TiledLayer:
	var name: String
	var layer_data: String #CSV
	var width: int
	var height: int
	var properties: Dictionary

	func _init(_name: String, _layer_data: String, _width: int, _height: int, _properties: Dictionary):
		name = _name
		layer_data = _layer_data
		width = _width
		height = _height
		properties = _properties

	func process_csv() -> PoolIntArray:
		var buf = ""
		var idata = PoolIntArray()
		for i in range(0, len(layer_data)):
			if layer_data[i] == ",":
				idata.append(int(buf.strip_edges()))
				buf = ""
			else:
				buf += layer_data[i]
		if buf != "":
			idata.append(int(buf.strip_edges()))
		return idata

	func make_godot_tilemap(tileset: TileSet, tilewidth: int, tileheight: int, tile_props: Dictionary):
		var node = load("res://addons/tiled_import/TiledMapLayer.cs").new()
		node.name = name
		node.tile_set = tileset
		node.cell_tile_origin = TileMap.TILE_ORIGIN_CENTER
		node.cell_size = Vector2(tilewidth, tileheight)
		node.cell_y_sort = true
		var idata = process_csv()
		for x in range(0, width):
			for y in range(0, height):
				node.set_cell(x, y, idata[y*width + x])
		node.Properties = properties
		for k in properties:
			for p in node.get_property_list():
				if p.name == k:
					node.set(k, properties[k])
					break
		node.TileProperties = tile_props
		return node
