extends KinematicBody2D

class_name Player

export var SPEED = 200 # max speed
export var ACCEL = 4000 # acceleration

onready var anim_player = $AnimationPlayer
onready var anim = $PlayerSprite
onready var hitbox = $HitBox
onready var hitbox_col = $HitBox/CollisionShape2D
onready var shooting_delay_timer = $ShootingDelay
onready var invincible_timer = $HitInvincibleDuration

var health = Global.player_maxhealth
var max_bombs = Global.starting_bombs
var bombs_active = 0
var explosion_range = Global.starting_explosion_range
var baguette_count = Global.starting_baguettes
var can_place_bomb = true
var can_shoot = true
var invincible = false
var motion = Vector2.ZERO # the Direction which the player goes

var speed_buffs = 0 # so viele speed buffs ma schau hod
var speed_buff = 50 # der buff der pro item zum speed dazua kummt

var pid = "1"
var vel = Vector2(0,0)
var game
var can_remove = false
var on_bomb = false
var bomb_moving_strength = 0
var facing = Vector2(0,0)

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
	game.update_info(int(pid), Items.SPEED, 0) # not implemented
	game.update_info(int(pid), Items.BOMBRANGE, explosion_range)
	game.update_info(int(pid), Items.EXPLOSIONSTRENGTH, 0) # not implemented
	game.update_info(int(pid), Items.BOMBMOVING, bomb_moving_strength)

func _process(delta):
	var axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(ACCEL*delta)
	else:
		apply_movement(axis*ACCEL*delta)
	motion = move_and_slide(motion)
	
	if axis != Vector2.ZERO:
		facing = axis
	
	_set_anim(axis)
	
	var target = motion*SPEED
	
	vel = target

# returns which direction the player is going to go
func get_input_axis():
	var axis = Vector2.ZERO
	if Input.is_action_pressed(pid + "move_forward"):
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
	motion = motion.clamped(SPEED)

func _input(event):
	if event.is_action_pressed(pid+"set_bomb") and can_place_bomb:
		if not on_bomb:
			on_bomb = true
			bombs_active += 1
			if bombs_active >= max_bombs:
				can_place_bomb = false
			get_parent().get_parent().place_bomb(self, get_global_transform().origin, explosion_range)
	
	if event.is_action_pressed(pid+"shoot") and can_shoot and baguette_count > 0:
		can_shoot = false
		baguette_count -= 1
		game.update_info(int(pid), Items.BAGUETTES, baguette_count)
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
			pass
		Items.BOMBRANGE:
			explosion_range += 1
			value = explosion_range - Global.starting_explosion_range
		Items.EXPLOSIONSTRENGTH:
			pass
		Items.BOMBMOVING:
			bomb_moving_strength += 1
			value = bomb_moving_strength
		_:
			print(pid+": "+str(item)+" is not implemented!")
	
	game.update_info(int(pid), item, value)

func get_hit():
	if not invincible:
		print(pid + ": I just got hit!")
		$Damage.play() #Plays Damage-Sound
		
		hitbox_col.set_deferred("disabled", true)
		
		invincible = true
		invincible_timer.start()
		anim_player.play("invincible", -1, 0.9/Global.player_invincible_time)
		
		health -= 1
		game.update_info(int(pid), Items.HEALTH, health)
		if health <= 0:
			_die()

func _die():
	# play death sound
	$Death.play()
	# tell the game
	game.player_died(int(pid))
	# death animation
	$AnimationPlayer.play("die")

func _on_ShootingDelay_timeout():
	can_shoot = true

func _on_HitInvincibleDuration_timeout():
	anim_player.play("default")
	hitbox_col.set_deferred("disabled", false)
	invincible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		if can_remove:
			queue_free()
		can_remove = true

func _on_Death_finished():
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
