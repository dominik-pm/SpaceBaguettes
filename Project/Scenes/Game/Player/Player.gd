extends KinematicBody2D

class_name Player

export var is_player_2 = false
export var SPEED = 150
export var ACCEL = 0.8

onready var anim = $AnimatedSprite

var player = "1"
var on_bomb = false
var vel = Vector2(0,0)
var facing = Vector2(0,0)

func _ready():
	facing = Vector2(1,0)

func init(pid, f):
	# set right sprite color --
	facing = f

func _process(delta):
	var dir = Vector2(0,0)
	if Input.is_action_pressed(player+"move_left"):
		dir = Vector2(-1, 0)
	if Input.is_action_pressed(player+"move_right"):
		dir = Vector2(1, 0)
	if Input.is_action_pressed(player+"move_forward"):
		dir = Vector2(0, -1)
	if Input.is_action_pressed(player+"move_backward"):
		dir = Vector2(0, 1)
	
	if dir != Vector2(0,0):
		facing = dir
	
	set_anim(dir)
	
	var target = dir*SPEED
	
	# something with accel here
	vel = target
	
	vel = move_and_slide(vel, Vector2.UP)

func _input(event):
	if event.is_action_pressed(player+"set_bomb"):
		if not on_bomb:
			get_parent().get_parent().place_bomb(self, get_global_transform().origin)
	
	if event.is_action_pressed(player+"shoot"):
		get_parent().get_parent().shoot_projectile(self, global_transform.origin)

func get_hit():
	print("I just got hit!")

func set_anim(d):
	# d is the moving direction
	if d == Vector2(-1, 0):
		anim.play("runningLeft")
	elif d == Vector2(1, 0):
		anim.play("runningRight")
	elif d == Vector2(0, -1):
		anim.play("runningUp")
	elif d == Vector2(0, 1):
		anim.play("runningDown")
	else:
		# not moving, so check the facing direction
		if facing == Vector2(-1, 0):
			anim.play("idleLeft")
		if facing == Vector2(1, 0):
			anim.play("idleRight")
		if facing == Vector2(0, -1):
			anim.play("idleUp")
		if facing == Vector2(0, 1):
			anim.play("idleDown")
