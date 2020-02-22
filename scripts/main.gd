extends Node2D


var current_node


func _ready():
	load_title_screen()


func load_title_screen():
	var ts = load("res://scenes/screens/title.tscn").instance()
	current_node = ts
	add_child(current_node)
	Utils.e_connect(ts, "start_playing", self, "on_start_playing")
	Utils.e_connect(ts, "quit", self, "on_quit")
	Utils.e_connect(ts, "credits", self, "on_credits")


func on_start_playing():
	current_node.queue_free()
	load_gameplay()


func on_quit():
	get_tree().quit()
	if OS.get_name() == "HTML5":
		OS.window_fullscreen = false


func load_gameplay():
	var gp = load("res://scenes/screens/gameplay.tscn").instance()
	current_node = gp
	add_child(current_node)
	Utils.e_connect(gp, "finished_game", self, "on_finished_game")
	Utils.e_connect(gp, "back_to_title", self, "on_back_to_title")


func on_back_to_title():
	current_node.queue_free()
	get_tree().paused = false
	load_title_screen()


func on_finished_game():
	current_node.queue_free()
	get_tree().paused = false
	load_game_complete()


func load_game_complete():
	var gc = load("res://scenes/screens/game_complete.tscn").instance()
	current_node = gc
	add_child(current_node)
	Utils.e_connect(gc, "credits", self, "on_credits")


func on_credits():
	current_node.queue_free()
	load_credits()


func load_credits():
	var c = load("res://scenes/screens/credits.tscn").instance()
	current_node = c
	add_child(current_node)
	Utils.e_connect(c, "return_to_title", self, "on_return_to_title")


func on_return_to_title():
	current_node.queue_free()
	load_title_screen()
