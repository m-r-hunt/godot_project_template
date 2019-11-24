extends Node2D


export var pixel_scale := 1


func _ready():
	window_resize()
	Utils.e_connect(get_viewport(), "size_changed", self, "window_resize")
	


func _process(_delta):
	var window_size = OS.window_size;
	var scale = 1;
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	while width*scale <= window_size.x and height*scale <= window_size.y:
		scale += 1
	scale -= 1
	if scale != pixel_scale:
		pixel_scale = int(max(1, scale))
		window_resize()



func window_resize():
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	assert(pixel_scale > 0 && typeof(pixel_scale) == TYPE_INT)
	get_viewport().set_size_override(true, OS.get_window_size() / pixel_scale)
	var x_diff = OS.window_size.x - width*pixel_scale
	var y_diff = OS.window_size.y - height*pixel_scale
	get_viewport().canvas_transform = Transform2D(0, Vector2(floor(x_diff/(2*pixel_scale)), floor(y_diff/(2*pixel_scale))))
