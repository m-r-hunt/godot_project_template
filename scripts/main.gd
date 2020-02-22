extends Node2D


var current_node


var state_machine = {
	"title": ["res://scenes/screens/title.tscn", ["start_playing", "on_start_playing"], ["quit", "on_quit"], ["credits", "on_credits"]],
	"gameplay": ["res://scenes/screens/gameplay.tscn", ["finished_game", "on_finished_game"], ["back_to_title", "on_back_to_title"]],
	"credits": ["res://scenes/screens/credits.tscn", ["return_to_title", "on_return_to_title"]],
	"game_complete": ["res://scenes/screens/game_complete.tscn", ["credits", "on_credits"]],
}


func _ready():
	load_state("title")


func load_state(s):
	if current_node:
		current_node.queue_free()
		current_node = null
	var state = state_machine[s]
	var node = load(state[0]).instance()
	add_child(node)
	for i in range(1, len(state)):
		Utils.e_connect(node, state[i][0], self, state[i][1])
	current_node = node


func on_start_playing():
	load_state("gameplay")


func on_quit():
	get_tree().quit()
	if OS.get_name() == "HTML5":
		OS.window_fullscreen = false


func on_back_to_title():
	get_tree().paused = false
	load_state("title")


func on_finished_game():
	get_tree().paused = false
	load_state("game_complete")


func on_credits():
	load_state("credits")


func on_return_to_title():
	load_state("title")
