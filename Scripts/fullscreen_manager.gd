extends Node


func _ready():
	pause_mode = PAUSE_MODE_PROCESS


func _input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
