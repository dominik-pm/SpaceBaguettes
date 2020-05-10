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
	Settings.save_settings()
	# animation here
	get_tree().quit()
# <-- MAIN MENU BUTTONS --

func _on_BtnBack_pressed():
	Settings.save_settings()
	play_menu.hide()
	sett_menu.hide()
	main_menu.show()


func start_game(player_count):
	$Fade.play("FadeOut") # maybe call the main menu, to do an animation
	
	# set player count
	var cnt = player_count
	if cnt < 2:
		cnt = 2
	elif cnt > 4:
		cnt = 4
	Global.player_count = cnt

# should also be in main menu
func _on_Fade_animation_finished(anim_name):
	if anim_name == "FadeOut":
		get_tree().change_scene("res://Scenes/Game/Game.tscn")
