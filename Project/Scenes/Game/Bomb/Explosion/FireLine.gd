extends Node2D

export var speed = 450
var dir = Vector2(0,0)
var dist = 1
var flying = false
var start_pos

func init(d, distance):
	dir = d
	dist = distance
	
	flying = true
	start_pos = transform.origin
	
	# direction stuff (i know this is all shet)
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
	
	# remove our self after the timespan of the bomb explosion
	yield(get_tree().create_timer(Global.bomb_explosion_time), "timeout")
	_remove_self()

# fade alpha and queue free once animation is finished
func _remove_self():
	$FadeOut.play("fade_out")
func _on_FadeOut_animation_finished(anim_name):
	queue_free()

var prev_d = null
func _process(delta):
	# only move when flying is true
	if flying:
		# move
		transform.origin += dir*delta*speed
		
		# calculate the distance to the target position
		var d = transform.origin - (start_pos+(dir*dist*Global.tilesize))
		d = d.length()
		
		# check if there was at least on frame (prev_d is only null at 1. frame) 
		if prev_d != null:
			# check if the distance to the target was less in the previous frame
			if prev_d < d:
				# if so, that mean it is going further than the target
				# so set flying to false
				flying = false
		
		prev_d = d # to save the distance to target of this frame

