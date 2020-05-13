extends KinematicBody2D

class_name Player

onready var anim_player = $AnimationPlayer
onready var anim = $PlayerSprite
onready var hitbox = $HitBox
onready var hitbox_col = $HitBox/CollisionShape2D
onready var shooting_delay_timer = $ShootingDelay
onready var invincible_timer = $HitInvincibleDuration
onready var muzzle = $Muzzle

# item relevant variables
var bombs_active = 0
var can_place_bomb = true
var can_shoot = true
var on_bomb = false

# movement variables
export var speed = 200
var motion = Vector2.ZERO # the direction in which the player goes
var last_move # last used direction
var vel = Vector2(0,0)
var facing = Vector2(0,0)

# items
var health = Global.player_maxhealth
var max_bombs = Global.starting_bombs
var baguette_count = Global.starting_baguettes
var speed_buffs = 0 # the current speed buffs
var explosion_range = Global.starting_explosion_range
var explosion_strength = Global.starting_explosion_strength
var bomb_moving_strength = 0 # 0: can not move bombs

# game relevant variables
var pid = "1"
var is_alive = true
var game
var can_remove = false
var invincible = false

func _ready():
	game = get_parent().get_parent()
	facing = Vector2(1,0)
	shooting_delay_timer.wait_time = Global.player_shoot_delay
	invincible_timer.wait_time = Global.player_invincible_time

func init(pos, p, f):
	global_transform.origin = pos
	pid = str(p)
	anim.init(int(pid))
	facing = f
	
	init_gui()

func init_gui():
	game.update_info(int(pid), Items.HEALTH, health)
	game.update_info(int(pid), Items.MOREBOMBS, max_bombs)
	game.update_info(int(pid), Items.BAGUETTES, baguette_count)
	game.update_info(int(pid), Items.SPEED, 0)
	game.update_info(int(pid), Items.BOMBRANGE, 0)
	game.update_info(int(pid), Items.EXPLOSIONSTRENGTH, 0)
	game.update_info(int(pid), Items.BOMBMOVING, bomb_moving_strength)

func _process(delta):
	var axis = get_input_axis()
	apply_friction(speed)
	apply_movement(axis*speed)
	motion = move_and_slide(motion)
	
	if axis != Vector2.ZERO:
		facing = axis
	
	_set_anim(axis)
	
	var target = motion*speed
	
	vel = target

# returns which direction the player is going to go
func get_input_axis():
	var axis = Vector2.ZERO
	
	if Input.is_action_just_pressed(pid + "move_forward"):
		last_move = pid+"move_forward"
	elif Input.is_action_just_pressed(pid + "move_backward"):
		last_move = pid+"move_backward"
	elif Input.is_action_just_pressed(pid + "move_right"):
		last_move = pid+"move_right"
	elif Input.is_action_just_pressed(pid + "move_left"):
		last_move = pid+"move_left"
	
	if Input.is_action_pressed(pid + "move_forward") and last_move == pid + "move_forward":
		axis.y = -1
	elif Input.is_action_pressed(pid + "move_backward") and last_move == pid + "move_backward":
		axis.y = 1
	elif Input.is_action_pressed(pid + "move_right") and last_move == pid + "move_right":
		axis.x = 1
	elif Input.is_action_pressed(pid + "move_left") and last_move == pid + "move_left":
		axis.x = -1
	
	elif Input.is_action_pressed(pid + "move_forward"):
		axis.y = -1
	elif Input.is_action_pressed(pid + "move_backward"):
		axis.y = 1
	elif Input.is_action_pressed(pid + "move_right"):
		axis.x = 1
	elif Input.is_action_pressed(pid + "move_left"):
		axis.x = -1

	return axis.normalized()

# reduces the current speed
func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

# apply speed
func apply_movement(accel):
	motion += accel
	motion = motion.clamped(speed)

func _input(event):
	if event.is_action_pressed(pid+"set_bomb") and can_place_bomb:
		if not on_bomb:
			on_bomb = true
			bombs_active += 1
			if bombs_active >= max_bombs:
				can_place_bomb = false
			get_parent().get_parent().place_bomb(self, get_global_transform().origin, explosion_range, explosion_strength)
	
	if event.is_action_pressed(pid+"shoot") and can_shoot and baguette_count > 0:
		can_shoot = false
		baguette_count -= 1
		game.update_info(int(pid), Items.BAGUETTES, baguette_count)
		shooting_delay_timer.start()
		var pos = game.get_tile_pos_center(muzzle.global_transform.origin)
		shoot(pos, muzzle.global_transform.origin)

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

# when one of current bombs explode
func bomb_exploded():
	bombs_active -= 1
	can_place_bomb = true

#if item gets picked up
func get_item(item):
	var value = 0
	
	match item:
		Items.HEALTH:
			if health < Global.player_maxhealth:
				health += 1
			value = health
		Items.MOREBOMBS:
			max_bombs += 1
			value = max_bombs
		Items.BAGUETTES:
			baguette_count += 1
			value = baguette_count
		Items.SPEED:
			if speed_buffs <= Global.player_max_speed_buffs:
				speed_buffs += 1
				speed += Global.speed_buff
			value = speed_buffs
		Items.BOMBRANGE:
			explosion_range += 1
			value = explosion_range - Global.starting_explosion_range
		Items.EXPLOSIONSTRENGTH:
			explosion_strength += 1
			value = explosion_strength - Global.starting_explosion_strength
		Items.BOMBMOVING:
			bomb_moving_strength += 1
			value = bomb_moving_strength
		_:
			print(pid+": "+str(item)+" is not implemented!")
	
	game.update_info(int(pid), item, value)

func get_hit():
	if not invincible:
		$Damage.play() # plays Damage-Sound
		
		game.player_hit(int(pid))
		
		hitbox_col.set_deferred("disabled", true)
		
		invincible = true
		invincible_timer.start()
		anim_player.play("invincible", -1, 0.9/Global.player_invincible_time)
		
		health -= 1
		game.update_info(int(pid), Items.HEALTH, health)
		if health <= 0:
			_die()

func _die():
	is_alive = false
	# play death sound
	$Death.play()
	# tell the game
	game.player_died(int(pid))
	# death animation
	$AnimationPlayer.play("die")
	# spawn gravestone
	var g = Preloader.gravestone.instance()
	game.add_node(g)#get_tree().root.add_node(g)
	g.global_transform.origin = game.get_tile_pos_center(muzzle.global_transform.origin)
	# disable movement/collisions
	set_process(false)
	hitbox_col.set_deferred("disabled", true)
	$EnvironmentCollider.set_deferred("disabled", true)

func _on_ShootingDelay_timeout():
	can_shoot = true

func _on_HitInvincibleDuration_timeout():
	anim_player.play("default")
	hitbox_col.set_deferred("disabled", false)
	invincible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	pass
	if anim_name == "die":
		if can_remove:
			queue_free()
		can_remove = true

func _on_Death_finished():
	pass
	if can_remove:
		queue_free()
	can_remove = true

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
