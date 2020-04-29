extends Control

onready var main_menu = $Main
onready var play_menu = $Play
onready var sett_menu = $Settings

func _ready():
	main_menu.show()
	play_menu.hide()
	sett_menu.hide()

# -- MAIN MENU BUTTONS -->
func _on_BtnSettings_pressed():
	main_menu.hide()
	sett_menu.show()

func _on_BtnPlay_pressed():
	main_menu.hide()
	play_menu.show()

func _on_BtnExit_pressed():
	# animation here
	get_tree().quit()
# <-- MAIN MENU BUTTONS --

func _on_BtnBack_pressed():
	play_menu.hide()
	sett_menu.hide()
	main_menu.show()

func _on_BtnStart_pressed():
	# animation here --
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
