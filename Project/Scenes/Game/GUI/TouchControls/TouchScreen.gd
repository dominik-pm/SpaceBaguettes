extends HBoxContainer

onready var stick = $Control3/JoyStickBG/JoyStickBtn
onready var btn_bomb = $HBoxContainer/Control2/BtnPlaceBomb
onready var btn_shoot = $HBoxContainer/Control/BtnShoot

export var alpha_threshhold = 22.5
var threshhold

func _ready():
	threshhold = sin(deg2rad(alpha_threshhold))
	
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
	
	if abs(dir.x) < threshhold:
		dir.x = 0
	if abs(dir.y) < threshhold:
		dir.y = 0
	
	print(dir.normalized())
	
	return dir.normalized()
