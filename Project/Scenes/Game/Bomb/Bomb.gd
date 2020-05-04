extends KinematicBody2D

class_name Bomb

onready var anim = $AnimationPlayer

var explosion_size
var can_collide = false
var can_free = false

# -- pushing --
var vel = Vector2(0,0)
var push_force = 64
# --

var game
var player

func _ready():
	$ExplodingTimer.wait_time = Global.bomb_explosion_time
	$ExplodingTimer.start()
	$Place.play()
	# start anim for bomb ---

func init(g, p, s):
	game = g
	player = p
	explosion_size = s
	add_collision_exception_with(player)
	anim.play("init", -1, 1.0/Global.bomb_explosion_time)

func _physics_process(delta):
	if can_collide:
		var collision = move_and_collide(vel*delta)
		#if collision:
		#	if collision.collider.is_in_group("PlayerHitbox"):
		#		vel = player.facing*push_force
				#apply_impulse(player.facing, push_force) # would prob be better (but doesnt work with kinematic body)

func _on_ExplodingTimer_timeout():
	explode()

func explode():
	$ExplodingTimer.stop()
	$ExplosionSound.play() #Plays Explosions-Sound if function is called
	
	# tell the player
	player.bomb_exploded()
	
	# tell the game
	game.explode(global_transform.origin, explosion_size)
	
	# Animation
	$Explosion.play("explode1")
	$Sprite.hide()
	
	# Stop physics
	$HitBox.disabled = true
	set_physics_process(false)

func _on_PushArea_body_exited(body):
	if body is player:
		print("player exited")
		remove_collision_exception_with(player)
		can_collide = true
		player.on_bomb = false

func _on_PushArea_body_entered(body):
	if can_collide:
		if body.is_in_group("PlayerHitbox"):
			var strength = body.player.bomb_moving_strength
			if strength > 0:
				print("player entered, pushing")
				$Kick.play() # play kick sound when hitted
				vel = player.facing*push_force*strength

func _on_Explosion_animation_finished():
	# small logic to only queue free, when the animation and the sound is finished
	if can_free:
		queue_free()
	can_free = true

func _on_ExplosionSound_finished():
	if can_free:
		queue_free()
	can_free = true
