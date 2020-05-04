extends KinematicBody2D

class_name Bomb

var explosion_size

var can_collide = false

# -- pushing --
var vel = Vector2(0,0)
var push_force = 64
# --

var game
var player

func _ready():
	$ExplodingTimer.start()
	$Place.play()
	# start anim for bomb ---

func init(g, p, s):
	game = g
	player = p
	explosion_size = s
	add_collision_exception_with(player)

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

func _on_Explosion_animation_finished():
	queue_free()

func _on_PushArea_body_exited(body):
	print("player exited")
	remove_collision_exception_with(player)
	can_collide = true
	player.on_bomb = false

func _on_PushArea_body_entered(body):
	if can_collide:
		print("player entered, pushing")
		if body.is_in_group("PlayerHitbox"):
			$Kick.play() #Play Kick Sound if hitted
			vel = player.facing*push_force
