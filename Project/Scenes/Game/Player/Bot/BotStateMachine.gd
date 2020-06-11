extends KinematicBody2D

class_name Bot

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
var can_place_bomb = false
var can_shoot = false
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
var game_started = false
var is_alive = true
var game
var can_remove = false
var invincible = false

# -- STATE MACHINE -->
var curr_state = null setget set_curr_state
var last_state = null
enum state {
	DEFENDING,
	ATTACKING,
	LOOTING,
	FARMING,
	MOVING,
	IDLE
}
onready var all_states = {
	state.DEFENDING : $States/Defending,
	state.ATTACKING : $States/Attacking,
	state.LOOTING 	: $States/Looting,
	state.FARMING 	: $States/Farming,
	state.MOVING 	: $States/Moving,
	state.IDLE 		: $States/Idle
}
# <-- STATE MACHINE --

# bot vars -->
var target_timeout = 3.5
var target_timer = null
var start_coord
var coord = Vector2(0,0)
var all_bombs = []
var all_items = []
var all_baguettes = []
var target = null setget set_target
var prev_target = null


func _ready():
	facing = Vector2(1,0)
	shooting_delay_timer.wait_time = Global.player_shoot_delay
	invincible_timer.wait_time = Global.player_invincible_time
	anim_player.play("default")
	
	target_timer = $States/TargetTimeout
	target_timer.one_shot = true
	target_timer.autostart = false
	target_timer.wait_time = target_timeout

func init(pos, p, f, g):
	
	game = g
	global_transform.origin = pos
	pid = str(p)
	anim.init(int(pid))
	facing = f
	_set_anim(vel)
	
	$Nametag/Label.text = Global.player_names[int(pid)-1]
	
	# bot knowledge
	all_bombs = game.bombs
	all_items = game.items
	all_baguettes = game.baguettes
	start_coord = game.get_coord(global_transform.origin)
	
	init_states()

func start():
	can_shoot = true
	can_place_bomb = true
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

func init_states():
	for state_idx in state:
		var idx = state[state_idx]
		all_states[idx].init(self, game)

func try_place_bomb():
	if can_place_bomb:
		if not on_bomb:
			# placing bomb
			print("Bot: placing bomb")
			
			on_bomb = true
			bombs_active += 1
			if bombs_active >= max_bombs:
				can_place_bomb = false
			game.update_current_bombs(int(pid), max_bombs-bombs_active)
			get_parent().get_parent().place_bomb(self, get_global_transform().origin, explosion_range, explosion_strength)


func try_shoot():
	if can_shoot and baguette_count > 0:
		can_shoot = false
		baguette_count -= 1
		game.update_info(int(pid), Items.BAGUETTES, baguette_count)
		game.shot_baguette(pid)
		shooting_delay_timer.start()
		var pos = game.get_tile_pos_center(muzzle.global_transform.origin)
		shoot(pos, muzzle.global_transform.origin)

func set_target(new_value):
	# check if we dont already have this value
	if target != new_value:
		prev_target = target
		target = new_value
		
		# we got a valid new target
		if target != null:
			print("Bot: set new target: " + str(target))
			target_timer.stop()
			target_timer.start()
func set_curr_state(state):
	if curr_state != state:
		print("Bot: changed from " + str(curr_state) + " to " + str(state))
	curr_state = state
func change_state(next_state):
	# only do change if it is a new state
	if curr_state != next_state:
		# if there was a curr_state, exit it
		if curr_state != null:
			curr_state.exit()
		
		last_state = curr_state
		self.curr_state = next_state

		print("Bot: changed state from: " + str(last_state) + " to:" + str(curr_state) + "!")
	elif next_state != null:
		# change from state to state (shouldnt happen)
		pass
		#print("Bot: tried to change to the same state again!")
	else:
		# change from null to null (can happen?)
		pass
func _process(delta):
	if game_started:
		
		coord = game.get_coord(muzzle.global_transform.origin)
		
		# -- GET STATE --
		
		# get new state and new target
		var new_target = null
		if curr_state in [state.IDLE, null] and target == null:
			for idx in all_states:
				new_target = all_states[idx].get_target()
				if new_target != null:
					self.curr_state = all_states[idx]
					break
			
			#new_target = all_states[state.ATTACKING].get_target()
			#if new_target != null:
			#	curr_state = all_states[state.ATTACKING]
			#else:
			#	new_target = all_states[state.FARMING].get_target()
			#	if new_target != null:
			#		curr_state = all_states[state.FARMING]
		
		## set the new target
		#if new_target != null:
		#	self.target = new_target
		
		# update current state
		if curr_state != null:
			if curr_state != all_states[state.DEFENDING]: # gets done later anyways
				new_target = curr_state.update(new_target)
				
				if new_target == null:
					print("Bot: current state returned null on update")
					curr_state.abort()
					self.curr_state = null
		
		
		# -- DEFENDING --
		# -> check if the new target is safe
		var def_target = all_states[state.DEFENDING].update(new_target)
		
		if def_target != null and def_target != new_target:
			#print("Bot: found def target to abort to: " + str(def_target))
			if curr_state != null:
				curr_state.abort()
			self.curr_state = all_states[state.DEFENDING]
			self.target = def_target
			new_target = null
		#else:
		#	print(str(new_target) + " is safe")
		
		
		# set the new target
		if new_target != null:
			self.target = new_target
		
		
		# -- PATHFINDING TO TARGET --
		var axis = Vector2.ZERO
		axis = get_dir(target)
		
		# -- move -->
		apply_friction(speed)
		apply_movement(axis*speed)
		motion = move_and_slide(motion)
		
		if axis != Vector2.ZERO:
			facing = axis
		
		_set_anim(axis)
		
		var target_vel = motion*speed
		vel = target_vel

# returns which direction the player is going to go
func get_dir(state_target):
	var dir = Vector2.ZERO
	
	#if state_target != null:
	#	if game.check_block(state_target) != 0:
	#		print("Bot: THIS IS NOT GOOD")
	
	if state_target == null:
		# the current state doesnt have a target
		if curr_state != null:
			curr_state.abort()
		self.curr_state = null
		self.target = null
	elif false:
		print(coord)
		print(state_target)
		var path = game.navigation.get_simple_path(muzzle.global_transform.origin, game.get_pos(state_target), true)
		#var path = game.navigation.get_simple_path(coord, state_target, false)
		print(path)
	else:
		#print("we got target")
		
		# the current state has a target to get to
		# -> get the dir for the target position
		
		var target_dist_x = abs(muzzle.global_transform.origin.x - (target.x*game.cellsize.x+(game.cellsize.x/2)))
		var target_dist_y = abs(muzzle.global_transform.origin.y - (target.y*game.cellsize.y+(game.cellsize.y/2)))
		
		#print("target distance: " + str(target_dist_x)+", " + str(target_dist_y))
		
		# -- PATHFINDING --> (currently can only do one turn)
		# check if lane free ! -------------------
		var next_block = coord
		if target_dist_x > game.cellsize.x/16:
			dir.x = (target.x*game.cellsize.x+(game.cellsize.x/2))-muzzle.global_transform.origin.x
			next_block = coord+dir.normalized()
		# when we dont need to anymove to x or there is a block, move y
		if dir.x == 0 or game.check_block(next_block) != 0:
			if target_dist_y > game.cellsize.y/16:
				dir.y = (target.y*game.cellsize.y+(game.cellsize.x/2))-muzzle.global_transform.origin.y
		# <-- PATHFINDING --
		
		
		if dir == Vector2.ZERO:
			# target hit!
			print("Bot: target hit!")
			#prev_target = target
			if curr_state != null:
				curr_state.target_reached()
				self.curr_state = null
			self.target = null
			#if target != prev_target:
			#	target_timer.start()
			#	print("Bot: new target: " + str(target))
			##print(dir)
			#change_state(null)
	
	return dir.normalized()

# checks if there is a clear path in a certain direction
func lane_free(pos, axis, r):
	for i in range(1, r+1):
		var block = Vector2(pos.x + i*axis.x, pos.y + i*axis.y)
		if game.check_block(block) != 0:
			return false
	return true

func _on_TargetTimeout_timeout():
	print("Bot: ran out of time for the target, setting it to null")
	self.target = null
	target_timer.stop()

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

func shoot(pos, player_pos):
	var b = Preloader.baguette.instance()
	b.init(game, self, facing, coord)
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
	can_place_bomb = true
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
			print(pid+": "+str(item)+" is not implemented!")
	
	game.update_info(int(pid), item, value)

func get_hit():
	if not invincible:
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
	game_started = false
	
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
