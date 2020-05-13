extends VBoxContainer

onready var btn_on = $ToggleFullscreen/ToggleOn
onready var btn_off = $ToggleFullscreen/ToggleOff

func _ready():
	var is_on = Settings.get_setting("video", "fullscreen")
	show_buttons(is_on)
	
	btn_on.connect("pressed", self, "_on_btnon_pressed")
	btn_off.connect("pressed", self, "_on_btnoff_pressed")
	
	Application.connect("toggled_fullscreen", self, "_on_manual_fullscreentoggle")

func show_buttons(is_on):
	if is_on:
		btn_off.show()
		btn_on.hide()
	else:
		btn_on.show()
		btn_off.hide()

func _on_manual_fullscreentoggle(is_on):
	show_buttons(is_on)

func _on_btnon_pressed():
	Settings.set_setting("video", "fullscreen", true)
	OS.window_fullscreen = true
	btn_off.show()
	btn_on.hide()

func _on_btnoff_pressed():
	Settings.set_setting("video", "fullscreen", false)
	OS.window_fullscreen = false
	btn_on.show()
	btn_off.hide()
