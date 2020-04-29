extends KinematicBody2D

export var explosion_size = 3

var vel = Vector2(0,0)

var can_collide = false
var push_force = 50

var game
var player

func _ready():
	$ExplodingTimer.start()
	#$AnimationPlayer.play("explode")

func init(g, p):
	game = g
	player = p
	add_collision_exception_with(player)
	player.on_bomb = true

func _physics_process(delta):
	if can_collide:
		var collision = move_and_collide(vel*delta)
		if collision:
			if collision.collider is Player:
				vel = player.facing*push_force
				#apply_impulse(pos, push_force) # would prob be better (but doesnt work with kinematic body)

func explode():
	game.explode(global_transform.origin, explosion_size)
	$CollisionShape2D.disabled = true
	#$MeshInstance2D.hide()
	$Bomb.hide()
	$ExplodingTimer.stop()
	set_physics_process(false)

func _on_ExplodingTimer_timeout():
	explode()

func _on_AnimatedSprite_animation_finished():
	queue_free()

func _on_Area2D_body_exited(body):
	remove_collision_exception_with(player)
	can_collide = true
	player.on_bomb = false
