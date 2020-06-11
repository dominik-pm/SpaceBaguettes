extends Control

export (NodePath) var rocket

onready var main_menu = $Main/Buttons
onready var play_menu = $Play
onready var sett_menu = $Settings
onready var conf_menu = $ConfigMenu
onready var help_menu = $HelpMenu
onready var click_snd = $Click
onready var start_snd = $Start
onready var start_snd2 = $Start2

var help_menu_open = false

func _ready():
	click_snd.stream.loop = false
	init_main_menu()
	
	rocket = get_node(rocket)
	rocket.fly_in()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if help_menu.visible:
			help_menu.hide()
		elif conf_menu.visible:
			conf_menu.hide()
		else:
			init_main_menu()

# -- MAIN MENU BUTTONS -->
func _on_BtnSettings_pressed():
	click_snd.play()
	sett_menu.show()
	main_menu.hide()
	help_menu.hide()
	conf_menu.hide()
	$Settings/BackButton/CenterContainer/BtnBack.grab_focus()

func _on_BtnPlay_pressed():
	click_snd.play()
	play_menu.show()
	main_menu.hide()
	help_menu.hide()
	conf_menu.hide()
	$Play/PlayMenu/VBox/Control/BtnStart.grab_focus()

func _on_BtnExit_pressed():
	Settings.save_settings()
	# animation here
	get_tree().quit()
# <-- MAIN MENU BUTTONS --

# -- BACK BUTTON -->
func _on_BtnBack_pressed():
	click_snd.play()
	Settings.save_settings()
	init_main_menu()
# <-- BACK BUTTON --

# -- OTHER BUTTONS -->
func _on_BtnConfiguration_pressed():
	conf_menu.visible = !conf_menu.visible
	if conf_menu.visible:
		help_menu.hide()
		$Click.play()

func _on_BtnHelp_pressed():
	help_menu.visible = !help_menu.visible
	if help_menu.visible:
		conf_menu.hide()
		$Click2.play()

func _on_BtnInfo_pressed():
	$Main/BtnInfo.toggle_info()
	if $Main/BtnInfo.is_shown:
		$Click2.play()
# <-- BOTHER BUTTONS --


func init_main_menu():
	main_menu.show()
	play_menu.hide()
	sett_menu.hide()
	conf_menu.hide()
	help_menu.hide()
	$Main/Buttons/CenterContainer2/BtnPlay.grab_focus()

func start_game():
	start_snd.play()
	start_snd2.play()
	$Fade.play("FadeOut")
	rocket.fly_away()

# should also be in main menu
func _on_Fade_animation_finished(anim_name):
	if anim_name == "FadeOut":
		get_tree().change_scene("res://Scenes/Game/Game.tscn")
