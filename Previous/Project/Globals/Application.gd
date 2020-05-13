extends Node

signal toggled_fullscreen

func _ready():
	OS.window_fullscreen = Settings.get_setting("video", "fullscreen")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Settings.save_settings()
		get_tree().quit()

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		emit_signal("toggled_fullscreen", OS.window_fullscreen)
