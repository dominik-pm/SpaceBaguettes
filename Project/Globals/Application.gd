extends Node

signal toggled_fullscreen

func _ready():
	OS.window_fullscreen = Settings.get_setting("video", "fullscreen")

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		emit_signal("toggled_fullscreen", OS.window_fullscreen)
