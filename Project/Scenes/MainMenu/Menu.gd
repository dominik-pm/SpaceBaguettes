extends Control

var help_menu_open = false

onready var main_menu = $Main/Buttons
onready var play_menu = $Play
onready var sett_menu = $Settings
onready var help_menu = $HelpMenu

func _ready():
	init_main_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if help_menu.visible:
			help_menu.hide()
		else:
			init_main_menu()

# -- MAIN MENU BUTTONS -->
func _on_BtnSettings_pressed():
	main_menu.hide()
	sett_menu.show()
	help_menu.hide()

func _on_BtnPlay_pressed():
	main_menu.hide()
	play_menu.show()
	help_menu.hide()

func _on_BtnExit_pressed():
	Settings.save_settings()
	# animation here
	get_tree().quit()
# <-- MAIN MENU BUTTONS --

func _on_BtnBack_pressed():
	Settings.save_settings()
	init_main_menu()

func _on_BtnHelp_pressed():
	help_menu.visible = !help_menu.visible

func init_main_menu():
	main_menu.show()
	play_menu.hide()
	sett_menu.hide()
	help_menu.hide()

func start_game():
	$Fade.play("FadeOut") # maybe call the main menu, to do an animation

# should also be in main menu
func _on_Fade_animation_finished(anim_name):
	if anim_name == "FadeOut":
		get_tree().change_scene("res://Scenes/Game/Game.tscn")
