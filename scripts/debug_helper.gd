extends Node


# Must be bools. Should turn on/off all permanent debug features this way.
const debug_settings = [
	"my_settings/debug/auto_maximize",
	"my_settings/debug/short_rounds",
]


func _ready():
	if OS.is_debug_build():
		print("I'm a debug build")
		if ProjectSettings.get_setting("my_settings/debug/auto_maximize"):
			OS.window_maximized = true
	else:
		# Ensure debug settings are disabled for release builds
		# Ideally we should expunge them all and also this script, 
		# but this is useful until a really "final" state
		print("I'm a release build")
		for setting in debug_settings:
			ProjectSettings.set_setting(setting, false)
