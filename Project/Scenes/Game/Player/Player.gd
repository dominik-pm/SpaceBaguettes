extends KinematicBody2D

class_name Player

export var SPEED = 150
export var ACCEL = 0.8

onready var anim_player = $AnimationPlayer
onready var anim = $AnimatedSprite
onready var hitbox = $HitBox
onready var shooting_delay_timer = $ShootingDelay
onready var invincible_timer = $HitInvincibleDuration

var health = Global.player_maxhealth
var max_bombs = Global.starting_bombs
var bombs_active = 0
var explosion_size = Global.starting_explosion_size
var baguette_count = Global.starting_baguettes
var can_place_bomb = true
var can_shoot = true
var invincible = false

var pid = "1"
var vel = Vector2(0,0)
var game
var on_bomb = false
var facing = Vector2(0,0)

func _ready():
	game = get_parent().get_parent()
	facing = Vector2(1,0)
	shooting_delay_timer.wait_time = Global.player_shoot_delay
	invincible_timer.wait_time = Global.player_invincible_time

func init(pos, p, f):
	global_transform.origin = pos
	pid = str(p)
	print(pid)
	# set right sprite color --
	facing = f

func _process(delta):
	var dir = Vector2(0,0)
	if Input.is_action_pressed(pid+"move_left"):
		dir = Vector2(-1, 0)
	if Input.is_action_pressed(pid+"move_right"):
		dir = Vector2(1, 0)
	if Input.is_action_pressed(pid+"move_forward"):
		dir = Vector2(0, -1)
	if Input.is_action_pressed(pid+"move_backward"):
		dir = Vector2(0, 1)
	
	if dir != Vector2(0,0):
		facing = dir
	
	_set_anim(dir)
	
	var target = dir*SPEED
	
	# something with accel here
	vel = target
	
	vel = move_and_slide(vel, Vector2.UP)

func _input(event):
	if event.is_action_pressed(pid+"set_bomb") and can_place_bomb:
		if not on_bomb:
			on_bomb = true
			bombs_active += 1
			if bombs_active >= max_bombs:
				can_place_bomb = false
			get_parent().get_parent().place_bomb(self, get_global_transform().origin, explosion_size)
	
	if event.is_action_pressed(pid+"shoot") and can_shoot and baguette_count > 0:
		can_shoot = false
		baguette_count -= 1
		print(pid+": baguettes left: " + str(baguette_count))
		shooting_delay_timer.start()
		var pos = game.get_shoot_pos(global_transform.origin)
		shoot(pos, global_transform.origin)

func shoot(pos, player_pos):
	var b = Preloader.baguette.instance()
	b.init(game, self, facing)
	game.add_node(b)
	
	b.add_collision_exception_with(hitbox)
	
	# so that the bullet always flies in the center of the tiles
	if facing.x == 0:
		b.global_transform.origin = Vector2(pos.x, player_pos.y)
	else:# player.facing.y == 0:
		b.global_transform.origin = Vector2(player_pos.x, pos.y)

func bomb_exploded():
	bombs_active -= 1
	can_place_bomb = true

func get_item(item):
	match item:
		Items.TESTBUFF:
			print(pid+": got test buff")
		_:
			print(pid+": "+str(item)+" is not implemented!")

func get_hit():
	if not invincible:
		print(pid + ": I just got hit!")
		$Damage.play() #Plays Damage-Sound
		
		$HitBox/CollisionShape2D.disabled = true
		
		invincible = true
		invincible_timer.start()
		anim_player.play("invincible")
		
		health -= 1
		if health <= 0:
			_die()

func _die():
	$Death.play() #Plays Death-Sound
	print(pid + ": im ded")

func _on_ShootingDelay_timeout():
	can_shoot = true

func _on_HitInvincibleDuration_timeout():
	anim_player.play("default")
	invincible = false

func _set_anim(d):
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
