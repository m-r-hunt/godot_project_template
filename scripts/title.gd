extends Node2D


signal start_playing
signal quit
signal credits

var selected := 0
onready var buttons = [$PlayButton, $CreditsButton, $QuitButton]

func _ready():
	Utils.e_connect($PlayButton, "pressed", self, "on_play_pressed")
	Utils.e_connect($QuitButton, "pressed", self, "on_quit_pressed")
	Utils.e_connect($CreditsButton, "pressed", self, "on_credits_pressed")
	sort_selection()


func sort_selection():
	for i in range(len(buttons)):
		buttons[i].set_selected(i == selected)


func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		selected = (selected + 1) % len(buttons)
	if Input.is_action_just_pressed("ui_up"):
		selected = (selected - 1)
		if selected < 0:
			selected += len(buttons)
	sort_selection()
	if Input.is_action_just_pressed("ui_accept"):
		match selected:
			0:
				emit_signal("start_playing")
			1:
				emit_signal("credits")
			2:
				emit_signal("quit")


func on_play_pressed():
	emit_signal("start_playing")


func on_quit_pressed():
	emit_signal("quit")


func on_credits_pressed():
	emit_signal("credits")
