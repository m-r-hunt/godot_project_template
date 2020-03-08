extends Node2D

tool


export var text := "" setget set_text


signal pressed


func _ready():
	Utils.e_connect($Button, "pressed", self, "on_pressed")


func set_text(t):
	text = t
	$Button.text = t


func on_pressed():
	emit_signal("pressed")


func set_selected(_selected: bool):
	pass
