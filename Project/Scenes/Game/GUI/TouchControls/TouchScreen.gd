extends HBoxContainer

onready var stick = $Control3/JoyStickBG/JoyStickBtn
onready var btn_bomb = $HBoxContainer/Control2/BtnPlaceBomb
onready var btn_shoot = $HBoxContainer/Control/BtnShoot

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
	
	# basti moch do
	if abs(dir.x) > abs(dir.y):
		dir.y = 0
	else:
		dir.x = 0
	
	return dir.normalized()
