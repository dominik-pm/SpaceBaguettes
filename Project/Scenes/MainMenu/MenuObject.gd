extends Sprite

export (NodePath) var relative_origin

export var is_still = false
export var respawn_interval = 60
export var spawn_time_offset = 1
export var rot_off_sprite_left = false
export var speed = 50
export var rotation_speed = 0

onready var timer = $Timer
onready var off_timer = $OffsetTimer

var moving = false
var dir
var start_pos_offset

func _ready():
	var angle = rotation
	if not rot_off_sprite_left:
		angle -= PI/2
	dir = -Vector2(cos(angle), sin(angle))
	
	relative_origin = get_node(relative_origin)
	start_pos_offset = transform.origin - relative_origin.global_transform.origin
	
	timer.wait_time = respawn_interval
	off_timer.wait_time = spawn_time_offset
	
	off_timer.start()
	

func _process(delta):
	if moving:
		transform.origin += dir*delta*speed
		rotate(deg2rad(rotation_speed*delta))
	elif not is_still:
		transform.origin = start_pos_offset + relative_origin.global_transform.origin

func _on_Timer_timeout():
	#print(name + " is respawning")
	moving = false
	
	transform.origin = start_pos_offset + relative_origin.global_transform.origin
	if is_still:
		transform.origin -= relative_origin.global_transform.origin
	
	off_timer.start()

func _on_OffsetTimer_timeout():
	moving = true
	timer.start()
