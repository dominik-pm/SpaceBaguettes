extends KinematicBody2D

const NETWORK_ERROR_DISTANCE = 5

onready var touchscreen = $CanvasLayer/TouchScreen

onready var anim_player = $AnimationPlayer
onready var anim = $PlayerSprite
onready var hitbox = $HitBox
onready var hitbox_col = $HitBox/CollisionShape2D
onready var shooting_delay_timer = $ShootingDelay
onready var invincible_timer = $HitInvincibleDuration
onready var muzzle = $Muzzle
onready var particles_damage = $Particles2D

# item relevant variables
var bombs_active = 0
var can_shoot = false
var on_bomb = false

# movement variables
remote var axis = Vector2.ZERO
remote var other_pos = Vector2.ZERO
export var speed = 200
var motion = Vector2.ZERO # the direction in which the player goes
var last_move_y # last used y-direction
var last_move_x # last used x-direction
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
var pid = null # "1"
var gp_index = ""
var kb_index = ""
var game_started = false
var is_alive = true
var game
var can_remove = false
var invincible = false

func _ready():
	facing = Vector2(1,0)
	shooting_delay_timer.wait_time = Global.player_shoot_delay
	invincible_timer.wait_time = Global.player_invincible_time
	anim_player.play("default")
	if pid != null:
		anim.init(int(pid))

func init(pos, p, f, g, nid):
	set_network_master(nid)
	
	name = str(nid)
	
	game = g
	global_transform.origin = pos
	pid = str(p)
	facing = f
	_set_anim(vel)
	
	if anim != null:
		anim.init(int(pid))
	
	$Nametag/Label.text = str(Global.player_names[int(pid)-1])
	
	gp_index = "1"
	kb_index = pid

func start():
	can_shoot = true
	game_started = true

func init_gui():
	game.update_info(int(pid), Items.HEALTH, health)
	game.update_info(int(pid), Items.MOREBOMBS, max_bombs)
	game.update_info(int(pid), Items.BAGUETTES, baguette_count)
	game.update_info(int(pid), Items.SPEED, 0)
	game.update_info(int(pid), Items.BOMBRANGE, 0)
	game.update_info(int(pid), Items.EXPLOSIONSTRENGTH, 0)
	game.update_info(int(pid), Items.BOMBMOVING, bomb_moving_strength)
	game.update_current_bombs(int(pid), max_bombs-bombs_active)

func _process(delta):
	if game_started:
		# network
		if is_network_master():
			# is playing
			rpc("update_puppet", axis, global_transform.origin)
			#rset_unreliable("axis", axis)
			#rset_unreliable("other_pos", global_transform.origin)
			axis = get_input_axis()
		else:
			# is a puppet
			if other_pos != Vector2.ZERO:
				# check if position is not far off, else correct it
				if (other_pos-global_transform.origin).length() > NETWORK_ERROR_DISTANCE:
					global_transform.origin = other_pos
		
		apply_friction(speed)
		apply_movement(axis*speed)
		motion = move_and_slide(motion)
		
		if axis != Vector2.ZERO:
			facing = axis
		
		_set_anim(axis)
		
		var target = motion*speed
		
		vel = target

remote func update_puppet(dir, pos):
	axis = dir
	other_pos = pos

# returns which direction the player is going to go
func get_input_axis():
	var input = Vector2.ZERO
	var axis = Vector2.ZERO
	var block = game.get_coord(muzzle.global_transform.origin)
	var curr_key = 0
	
	# if on mobile, get the input from the touchscreen
	if Global.is_mobile:
		input = touchscreen.get_dir()
	else:
		if (Input.is_action_just_pressed(kb_index + "move_forward") or Input.is_action_just_pressed(gp_index + "move_forward_gp")):
			last_move_y = kb_index+"move_forward"
		elif (Input.is_action_just_pressed(kb_index + "move_backward") or Input.is_action_just_pressed(gp_index + "move_backward_gp")):
			last_move_y = kb_index+"move_backward"
		if (Input.is_action_just_pressed(kb_index + "move_right") or Input.is_action_just_pressed(gp_index + "move_right_gp")):
			last_move_x = kb_index+"move_right"
		elif (Input.is_action_just_pressed(kb_index + "move_left") or Input.is_action_just_pressed(gp_index + "move_left_gp")):
			last_move_x = kb_index+"move_left"
			
		if (Input.is_action_pressed(kb_index + "move_forward") or Input.is_action_pressed(gp_index + "move_forward_gp")):
			input.y = -1
		elif (Input.is_action_pressed(kb_index + "move_backward") or Input.is_action_pressed(gp_index + "move_backward_gp")):
			input.y = 1
		if (Input.is_action_pressed(kb_index + "move_right") or Input.is_action_pressed(gp_index + "move_right_gp")):
			input.x = 1
		elif (Input.is_action_pressed(kb_index + "move_left") or Input.is_action_pressed(gp_index + "move_left_gp")):
			input.x = -1
	
	if input.y < 0:
		curr_key += 1
	elif input.y > 0:
		curr_key += 1
	if input.x > 0:
		curr_key += 1
	elif input.x < 0:
		curr_key += 1
	
	if !Global.is_mobile:
		if input.y < 0 and last_move_y == kb_index + "move_forward":
			if curr_key >= 2 and game.check_block(Vector2(block.x, block.y-1)) != 0:
				axis.y = -0.15
			else:
				axis.y = -1
		elif input.y > 0 and last_move_y == kb_index + "move_backward":
			if curr_key >= 2 and game.check_block(Vector2(block.x, block.y+1)) != 0:
				axis.y = 0.15
			else:
				axis.y = 1
		if input.x > 0 and last_move_x == pid + "move_right":
			if curr_key >= 2 and game.check_block(Vector2(block.x+1, block.y)) != 0:
				axis.x = 0.15
			else:
				axis.x = 1
		elif input.x < 0 and last_move_x == kb_index + "move_left":
			if curr_key >= 2 and game.check_block(Vector2(block.x-1, block.y)) != 0:
				axis.x = -0.15
			else:
				axis.x = -1
		
	if axis.y == 0:
		if input.y < 0:
			if curr_key >= 2 and game.check_block(Vector2(block.x, block.y-1)) != 0:
				axis.y = -0.15
			else:
				axis.y = -1
		elif input.y > 0:
			if curr_key >= 2 and game.check_block(Vector2(block.x, block.y+1)) != 0:
				axis.y = 0.15
			else:
				axis.y = 1
	
	if axis.x == 0:
		if input.x > 0:
			if curr_key >= 2 and game.check_block(Vector2(block.x+1, block.y)) != 0:
				axis.x = 0.15
			else:
				axis.x = 1
		elif input.x < 0:
			if curr_key >= 2 and game.check_block(Vector2(block.x-1, block.y)) != 0:
				axis.x = -0.15
			else:
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
	if is_network_master() and is_alive and game_started:
		
		if (event.is_action_pressed("1set_bomb") or Input.is_action_pressed("1set_bomb_gp") or touchscreen.is_bomb_pressed()):
			if not game.pause_menu.visible:
				if bombs_active < max_bombs:
					if not on_bomb:
						on_bomb = true
						rpc("place_bomb", muzzle.get_global_transform().origin)
		
		if (event.is_action_pressed("1shoot") or Input.is_action_pressed("1shoot_gp") or touchscreen.is_shoot_pressed()) and can_shoot and baguette_count > 0:
			if not game.pause_menu.visible:
				can_shoot = false
				shooting_delay_timer.start()
				var pos = game.get_tile_pos_center(muzzle.global_transform.origin)
				rpc("shoot", pos)

sync func place_bomb(pos):
	bombs_active += 1
	game.update_current_bombs(int(pid), max_bombs-bombs_active)
	game.place_bomb(self, pos, explosion_range, explosion_strength) 

sync func shoot(pos):
	baguette_count -= 1
	game.update_info(int(pid), Items.BAGUETTES, baguette_count)
	game.shot_baguette(pid)
	
	var player_pos = muzzle.global_transform.origin
	var b = Preloader.baguette.instance()
	b.init(game, self, facing, game.get_coord(pos))
	game.add_node(b)
	b.add_collision_exception_with(hitbox)
	# so that the bullet always flies in the center of the tiles
	if facing.x == 0:
		# player facing down/up
		b.global_transform.origin = Vector2(pos.x, player_pos.y)
	else:# player.facing.y == 0:
		# player facing left/right
		b.global_transform.origin = Vector2(player_pos.x, pos.y)

# when one of current bombs explode
func bomb_exploded():
	bombs_active -= 1
	game.update_current_bombs(int(pid), max_bombs-bombs_active)

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
			print("1: "+str(item)+" is not implemented!")
	
	game.update_info(int(pid), item, value)

func get_hit():
	#if Network.local_id == 1:
	#	if not invincible:
	#		rpc("_get_hit")
	if is_network_master() and not invincible:
		rpc("_get_hit")

remotesync func _get_hit():
	$Damage.play() # plays Damage-Sound
	
	# activate the particles
	particles_damage.emitting = true
	
	# tell the game
	game.player_hit(int(pid))
	
	# disable the hitbox
	hitbox_col.set_deferred("disabled", true)
	
	# invincible stuff
	invincible = true
	invincible_timer.start()
	anim_player.play("invincible", -1, 0.9/Global.player_invincible_time)
	
	# health logic
	health -= 1
	game.update_info(int(pid), Items.HEALTH, health)
	if health <= 0:
		_die()

func disable_player():
	# death animation
	anim_player.play("die")
	# disable movement/collisions
	set_process(false)
	hitbox_col.set_deferred("disabled", true)
	$EnvironmentCollider.set_deferred("disabled", true)

func _die():
	is_alive = false
	
	disable_player()
	
	# play death sound
	$Death.play()
	
	# tell the game
	game.player_died(int(pid))
	
	# spawn gravestone
	var g = Preloader.gravestone.instance()
	game.add_node(g)#get_tree().root.add_node(g)
	g.global_transform.origin = game.get_tile_pos_center(muzzle.global_transform.origin)

func _on_ShootingDelay_timeout():
	can_shoot = true

func _on_HitInvincibleDuration_timeout():
	if is_alive:
		anim_player.play("default")
		hitbox_col.set_deferred("disabled", false)
		invincible = false

# to remove the player completely (not necessary ?)
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
	if d.y != 0 and abs(d.y) > abs(d.x):
		if d.y < 0:
			anim.play("runningUp")
			facing = Vector2(0, -1)
		elif d.y > 0:
			anim.play("runningDown")
			facing = Vector2(0, 1)
			
	elif d.x != 0 and abs(d.x) >= abs(d.y):
		if d.x < 0:
			anim.play("runningLeft")
			facing = Vector2(-1, 0)
		elif d.x > 0:
			anim.play("runningRight")
			facing = Vector2(1, 0)

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
