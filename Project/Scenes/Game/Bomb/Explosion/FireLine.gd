extends Node2D

export var speed = 300
var dir = Vector2(0,0)
var dist = 1
var flying = false
var start_pos

func init(d, distance):
	# direction stuff (i know this is all shet)
	dir = d
	var a = (Vector2(0, 1).angle_to(dir))
	rotation = a
	if dir.y == 0:
		a -= PI
	
	# init the particle emitters 
	for child in get_children():
		if child is Particles2D:
			child.one_shot = true
			child.emitting = true
			child.lifetime = Global.bomb_explosion_duration
			
			# set correct direction for the particles
			if !child.local_coords:
				child.process_material = child.process_material.duplicate()
				child.process_material.angle = rad2deg(a)
	
	dist = distance
	
	flying = true
	start_pos = transform.origin
	
	yield(get_tree().create_timer(Global.bomb_explosion_time), "timeout")
	_remove_self()

func _remove_self():
	$FadeOut.play("fade_out")

func _on_FadeOut_animation_finished(anim_name):
	queue_free()

func _process(delta):
	if flying:
		transform.origin += dir*delta*speed
		var d = transform.origin - (start_pos+(dir*dist*Global.tilesize))
		if d.length() < 1:
			flying = false

