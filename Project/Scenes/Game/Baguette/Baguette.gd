extends KinematicBody2D

class_name Baguette

export var speed = 425

var game
var player
var dir
var coord : Vector2

func _ready():
	$AnimationPlayer.play("rattle")
	$Shoot.play() #plays shoot sound
	
	look_at(dir)
	if dir == Vector2(-1, 0):
		$Sprites/Baguette.flip_v = true # fix orientation
	
	# set correct direction for the particles
	for child in get_children():
		if child is Particles2D:
			if !child.local_coords:
				child.process_material = child.process_material.duplicate()
				child.process_material.angle = -90+rotation_degrees

func init(g, p, d, c):
	game = g
	player = p
	add_collision_exception_with(player)
	add_collision_exception_with(player.hitbox)
	dir = d
	coord = c
	
	if dir.x == 0:
		$Sprites/Baguette.hide()
	else:
		$Sprites/BaguetteTop.hide()

func _physics_process(delta):
	var collision = move_and_collide(dir*speed*delta)
	if collision:
		var collider = collision.collider
		if collider.is_in_group("Baguette"):
			collider.destroy()
			destroy()
		elif collider is PlayerHitbox:
			game.player_hit_enemy(player.pid) # for stats
			collider.player.get_hit()
			destroy()
		elif collider is Bomb:
			collider.explode()
			destroy()
		elif collider is Player or collider is Bot:
			# dont do anything, bc this is the environment collider for the player
			pass
		else:
			# collider is a wall
			
			# create impact effect
			var i = Preloader.effect_impact.instance()
			game.add_node(i)
			i.global_transform.origin = collision.position
			i.init(dir)
			
			game.bullet_hit(collision.position, dir, player.pid)
			destroy()

func destroy():
	$Sprites.hide()
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	
	# stop the emitting of the particles and remove self when every particle is gone
	var ttl = 1
	for child in get_children():
		if child is Particles2D:
			if child.lifetime > ttl:
				ttl = child.lifetime
			child.emitting = false
	
	yield(get_tree().create_timer(ttl), "timeout")
	queue_free()
