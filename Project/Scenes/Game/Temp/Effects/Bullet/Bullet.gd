extends KinematicBody2D

class_name Projectile

export var speed = 250

var game
var dir

func _ready():
	$AnimationPlayer.play("rattle")

func init(g, p, d):
	game = g
	add_collision_exception_with(p)
	dir = d
	
	look_at(dir)
	
	for child in get_children():
		if child is Particles2D:
			if !child.local_coords:
				child.process_material = child.process_material.duplicate()
				child.process_material.angle = -90+rotation_degrees

func _physics_process(delta):
	var collision = move_and_collide(dir*speed*delta)
	if collision:
		var collider = collision.collider
		if collider.is_in_group("Projectile"):
			collider.destroy()
			destroy()
		elif collider.is_in_group("Player"):
			# maybe damage him
			collider.get_hit()
			destroy()
		elif collider.is_in_group("Bomb"):
			# let the bomb explode
			collider.explode()
			destroy()
		else:
			# collider is a wall
			game.bullet_hit(collision.position, dir)
			destroy()

func destroy():
	$Bullet.hide()
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	
	var ttl = 1
	for child in get_children():
		if child is Particles2D:
			if child.lifetime > ttl:
				ttl = child.lifetime
			child.emitting = false
	
	yield(get_tree().create_timer(ttl), "timeout")
	queue_free()
