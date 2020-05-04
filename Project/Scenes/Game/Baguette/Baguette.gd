extends KinematicBody2D

class_name Baguette

export var speed = 250

var game
var dir

func _ready():
	$AnimationPlayer.play("rattle")
	$Shoot.play() #plays shoot sound
	
	look_at(dir)
	
	# set correct direction for the particles
	for child in get_children():
		if child is Particles2D:
			if !child.local_coords:
				child.process_material = child.process_material.duplicate()
				child.process_material.angle = -90+rotation_degrees

func init(g, p, d):
	game = g
	add_collision_exception_with(p)
	dir = d
	
	if dir.x == 0:
		$"Sprites/Baguette".hide()
	else:
		$"Sprites/BaguetteTop".hide()

func _physics_process(delta):
	var collision = move_and_collide(dir*speed*delta)
	if collision:
		var collider = collision.collider
		if collider.is_in_group("Baguette"):
			collider.destroy()
			destroy()
		elif collider is PlayerHitbox:
			collider.player.get_hit()
			destroy()
		elif collider is Bomb:
			collider.explode()
			destroy()
		elif collider is Player:
			# dont do anything, bc this is the environment collider for the player
			pass
		else:
			# collider is a wall
			game.bullet_hit(collision.position, dir)
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
