extends Node2D


signal return_to_title


func _ready():
	Utils.e_connect($TitleButton, "pressed", self, "on_title_pressed")
	$TitleButton.set_selected(true)


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("return_to_title")


func on_title_pressed():
	emit_signal("return_to_title")
