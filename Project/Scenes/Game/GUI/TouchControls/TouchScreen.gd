extends HBoxContainer

onready var stick = $Control3/JoyStickBG/JoyStickBtn
onready var btn_bomb = $HBoxContainer/Control2/BtnPlaceBomb
onready var btn_shoot = $HBoxContainer/Control/BtnShoot

export var sens = 0.1

func _ready():
	if not Global.is_mobile:
		hide()

func is_bomb_pressed():
	return Global.is_mobile and btn_bomb.is_pressed()
func is_shoot_pressed():
	return Global.is_mobile and btn_shoot.is_pressed()

func get_value():
	return stick.get_value()

func get_dir():
	var dir = stick.get_value()
	
	if abs(dir.x) < sens:
		dir.x = 0
	if abs(dir.y) < sens:
		dir.y = 0	
	
	return dir.normalized()
