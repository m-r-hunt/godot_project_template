extends Node2D

var selected := 0
onready var buttons = [$PauseScreen/ResumeButton, $PauseScreen/TitleButton]
var paused := false


signal back_to_title
signal finished_game


func _ready():
	Utils.e_connect($PauseScreen/ResumeButton, "pressed", self, "on_resume_pressed")
	Utils.e_connect($PauseScreen/TitleButton, "pressed", self, "on_title_pressed")
	sort_selection()
	
	Utils.e_connect($Button, "pressed", self, "on_button_pressed") # Throwaway


# Throwaway
func on_button_pressed():
	emit_signal("finished_game")


func sort_selection():
	for i in range(len(buttons)):
		buttons[i].set_selected(i == selected)


func on_resume_pressed():
	paused = false
	get_tree().paused = false
	$PauseScreen.visible = false


func on_title_pressed():
	emit_signal("back_to_title")


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		paused = !paused
		if paused:
			get_tree().paused = true
			$PauseScreen.visible = true
			selected = 0
		else:
			get_tree().paused = false
			$PauseScreen.visible = false
	if paused:
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
					get_tree().paused = false
					$PauseScreen.visible = false
					paused = false
					$PausePlayer.play()
				1:
					emit_signal("back_to_title")
