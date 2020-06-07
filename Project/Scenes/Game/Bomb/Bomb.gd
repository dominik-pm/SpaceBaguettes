extends KinematicBody2D

class_name Bomb

onready var anim = $AnimationPlayer

var explosion_size
var explosion_strength
var can_collide = false
var can_free = false

# -- pushing --
var vel = Vector2(0,0)
var push_force = 64
# --

var game
var player
var coord = Vector2(0,0)

func _ready():
	$ExplodingTimer.wait_time = Global.bomb_explosion_time
	$ExplodingTimer.start()
	$Place.play()
	# start anim for bomb ---

func init(g, p, c, e_range, e_strenth):
	game = g
	player = p
	coord = c
	explosion_size = e_range
	explosion_strength = e_strenth
	add_collision_exception_with(player)
	anim.play("init", -1, 1.0/Global.bomb_explosion_time)

func _physics_process(delta):
	if can_collide:
		var collision = move_and_collide(vel*delta)
		if vel.length() > 0:
			coord = game.get_coord($Center.global_transform.origin)
		if collision:
			var body = collision.collider
			if body is Player:
				var strength = body.bomb_moving_strength
				if strength > 0:
					print("player entered, pushing")
					$Kick.play() # play kick sound when hitted
					vel = player.facing*push_force*strength
			else:
				vel = Vector2(0,0)

func _on_ExplodingTimer_timeout():
	explode()

func explode():
	$ExplodingTimer.stop()
	$ExplosionSound.play()
	$ExplosionSound2.play()
	
	can_collide = false
	
	# tell the player
	var wr  = weakref(player)
	if wr.get_ref(): # check if the player is not freed (died)
		player.bomb_exploded()
	
	# tell the game
	game.explode($Center.global_transform.origin, explosion_size, explosion_strength, player.pid)
	
	# Animation
	randomize()
	var i = (randi() % 3) + 1
	$Explosion.play("explode"+str(i))
	$Sprite.hide()
	
	# Stop physics
	$HitBox.disabled = true
	set_physics_process(false)

func _on_PushArea_body_exited(body):
	if body == player:
		remove_collision_exception_with(player)
		can_collide = true
		player.on_bomb = false

func _on_PushArea_body_entered(body):
	if can_collide:
		#if body.is_in_group("PlayerHitbox"):
		if body is Player:
			#var strength = body.player.bomb_moving_strength
			var strength = body.bomb_moving_strength
			if strength > 0:
				print("player entered, pushing")
				$Kick.play() # play kick sound when hitted
				vel = player.facing*push_force*strength

func _on_Explosion_animation_finished():
	$Explosion.hide()
	# small logic to only queue free, when the animation and the sound is finished
	if can_free:
		queue_free()
	can_free = true

func _on_ExplosionSound2_finished():
	if can_free:
		queue_free()
	can_free = true
