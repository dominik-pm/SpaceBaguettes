extends KinematicBody2D

class_name Bot1

onready var anim_player = $AnimationPlayer
onready var anim = $PlayerSprite
onready var hitbox = $HitBox
onready var hitbox_col = $HitBox/CollisionShape2D
onready var shooting_delay_timer = $ShootingDelay
onready var invincible_timer = $HitInvincibleDuration
onready var muzzle = $Muzzle
onready var particles_damage = $Particles2D

# -- STATE MACHINE -->
var current_state = states.IDLE
enum states {
	IDLE,
	BOMBING,
	SHOOTING,
	RUNNING
}
# <-- STATE MACHINE --

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

# bot vars
var start_coord
var coord = Vector2(0,0)
var all_bombs = []
var all_baguettes = []
var target_pos = Vector2.ZERO


func _ready():
	facing = Vector2(1,0)
	shooting_delay_timer.wait_time = Global.player_shoot_delay
	invincible_timer.wait_time = Global.player_invincible_time
	anim_player.play("default")

func init(pos, p, f, g):
	
	game = g
	global_transform.origin = pos
	pid = str(p)
	anim.init(int(pid))
	facing = f
	_set_anim(vel)
	
	$Nametag/Label.text = "Bot "+ str(pid) #Global.player_names[int(pid)-1]
	
	# bot knowledge
	all_bombs = game.bombs
	start_coord = game.get_coord(global_transform.origin)
	all_baguettes = game.baguettes

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

# bot method
func not_on_exception():
	var dist_to_start = 2
	
	if abs(coord.x - start_coord.x) >= dist_to_start:
		return true
	elif abs(coord.y - start_coord.y) >= dist_to_start:
		return true
	else:
		return false

func _process(delta):
	if game_started:
		# BOT CODE ----
		var axis = Vector2.ZERO
		coord = game.get_coord(muzzle.global_transform.origin)
		
		if current_state == states.BOMBING:
			if can_place_bomb and not_on_exception():
				if not on_bomb:
					# placing bomb
					print("Bot: placing bomb")
					current_state = states.IDLE
					
					on_bomb = true
					bombs_active += 1
					if bombs_active >= max_bombs:
						can_place_bomb = false
					game.update_current_bombs(int(pid), max_bombs-bombs_active)
					get_parent().get_parent().place_bomb(self, get_global_transform().origin, explosion_range, explosion_strength)
				current_state = states.IDLE
			else:
				current_state = states.IDLE
		elif current_state == states.SHOOTING:
			if can_shoot and baguette_count > 0:
				current_state = states.IDLE
				
				can_shoot = false
				baguette_count -= 1
				game.update_info(int(pid), Items.BAGUETTES, baguette_count)
				shooting_delay_timer.start()
				var pos = game.get_tile_pos_center(muzzle.global_transform.origin)
				shoot(pos, muzzle.global_transform.origin)
			elif baguette_count == 0:
				current_state == states.IDLE
		elif current_state == states.RUNNING:
			axis = get_dir()
			
			if axis == Vector2.ZERO:
				print("on wall")
				current_state = states.BOMBING
		elif current_state == states.IDLE:
			# figure out what to do
			current_state = states.RUNNING
		
		# movement
		apply_friction(speed)
		apply_movement(axis*speed)
		motion = move_and_slide(motion)
		
		if axis != Vector2.ZERO:
			facing = axis
		
		_set_anim(axis)
		
		var target = motion*speed
		vel = target

# returns which direction the player is going to go
func get_dir():
	var dir = Vector2.ZERO
	
	# defensive manouver
	if target_pos == Vector2.ZERO or true:
		# only do if we dont already have a target position
	
		# check if a bomb could harm us:
		var pos = coord
		
		var bomb = is_bomb_explosion_in_range(pos)
		if bomb != null:
			# there is a bomb that can harm us
			
			# check if we can walk left/right
			if lane_free(coord, Vector2(1, 0), bomb.explosion_size + 1):
				target_pos = Vector2(pos.x + bomb.explosion_size + 1, pos.y)
			elif lane_free(coord, Vector2(-1, 0), bomb.explosion_size + 1):
				target_pos = Vector2(pos.x - bomb.explosion_size - 1, pos.y)
			else:
				# check if we can escapse on y
				if bomb.explosion_size >= abs(bomb.coord.y-pos.y):
					if lane_free(coord, Vector2(0, 1), bomb.explosion_size + 1):
						target_pos = Vector2(pos.x, pos.y + bomb.explosion_size + 1)
					elif lane_free(coord, Vector2(0, -1), bomb.explosion_size + 1):
						target_pos = Vector2(pos.x, pos.y - bomb.explosion_size - 1)
		if target_pos != Vector2.ZERO:
			print("Bot: found defensive target: " + str(target_pos))
		
		# check if a baguette could harm us:
		var baguette = is_baguette_danger(pos)
		if baguette != null:
			# a baguette is in line
			print(pid + " sees a baguette in line")
	
	# offensive manouver
	if target_pos == Vector2.ZERO:
		# move to a crate
		# 1. get crates in a radius of 3
		var nearby_crates = []
		for x in range(-3, 4):
			for y in range(-3, 4):
				var p = coord+Vector2(x, y)
				if game.check_block(p) == 1:
					# block is a crate
					nearby_crates.push_back(p)
		if nearby_crates.size() > 0:
			# 2. get the nearest one
			var nearest = null
			var crate = null
			for c in nearby_crates:
				var dist = (c-coord).length()
				if nearest == null or dist <= nearest:
					if dist == nearest:
						pass # Make it 50/50 to switch over
					nearest = dist
					crate = c
			if crate != null:
				target_pos = crate+(coord-crate).normalized()
			else:
				print("Bot: bot.gd:<223 error")
		else:
			print("Bot: no nearby crates :(")
		
		if (target_pos != Vector2.ZERO):
			print("Bot: target set: " + str(target_pos))
	
	# check if target is save
	var bo = is_bomb_explosion_in_range(target_pos)
	var ba = is_baguette_danger(target_pos)
	if bo != null or ba != null:
		target_pos = Vector2.ZERO
		print("Bot: target dangerous, aborted")
	
	if target_pos == Vector2.ZERO:
		current_state = states.IDLE
		dir = Vector2.ZERO
	else:
		# we got a target to get to
		
		# get the dir for the target position
		var target_dist_x = abs(muzzle.global_transform.origin.x - (target_pos.x*game.cellsize.x+(game.cellsize.x/2)))
		var target_dist_y = abs(muzzle.global_transform.origin.y - (target_pos.y*game.cellsize.y+(game.cellsize.y/2)))
		
		#print("target distance: " + str(target_dist_x)+", " + str(target_dist_y))
		
		if target_dist_x > game.cellsize.x/8:
			dir.x = (target_pos.x*game.cellsize.x+(game.cellsize.x/2))-muzzle.global_transform.origin.x
		elif target_dist_y > game.cellsize.y/8:
			dir.y = (target_pos.y*game.cellsize.y+(game.cellsize.x/2))-muzzle.global_transform.origin.y
		else:
			# target hit!
			print("target hit!")
			target_pos = Vector2.ZERO

	return dir.normalized()

func lane_free(pos, axis, r):
	for i in range(1, r+1):
		var block = Vector2(pos.x + i*axis.x, pos.y + i*axis.y)
		if game.check_block(block) != 0:
			return false
	return true
func is_bomb_explosion_in_range(pos):
	for bomb in all_bombs:
		if bomb.coord.x == pos.x or bomb.coord.y == pos.y:
			# a bomb is in line
			# check if its explosion strength could be dangerous
			if bomb.explosion_size != null:
				if bomb.explosion_size >= abs(bomb.coord.x-pos.x):
					print(abs(bomb.coord.x-pos.x))
					return bomb
	return null
func is_baguette_danger(pos):
	for baguette in all_baguettes:
		if baguette.coord.x == coord.x:
			# baguette has same x
			var dist = (pos.x-baguette.coord.x)
			if baguette.dir.x * dist > 0: # x*y -> x and y are both negative or positive
				# baguette is flying towards us
				if lane_free(baguette.coord, Vector2(baguette.dir.x, 0), dist):
					# baguette can hit us
					print("baguette can hit us!")
		elif baguette.coord.y == coord.y:
			# baguette has same y
			var dist = (pos.y-baguette.coord.y)
			if baguette.dir.y * dist > 0: # x*y -> x and y are both negative or positive
				# baguette is flying towards us
				if lane_free(baguette.coord, Vector2(baguette.dir.y, 0), dist):
					# baguette can hit us
					print("baguette can hit us!")


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
