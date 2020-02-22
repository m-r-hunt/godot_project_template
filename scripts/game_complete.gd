extends Node2D


signal credits


func _ready():
	Utils.e_connect($CreditsButton, "pressed", self, "on_credits_pressed")
	$CreditsButton.set_selected(true)


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("credits")


func on_credits_pressed():
	emit_signal("credits")
