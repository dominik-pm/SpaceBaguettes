extends Sprite

export (NodePath) var relative_origin

export var respawn_interval = 60
export var rot_off_sprite_left = false
export var speed = 50
export var rotation_speed = 0

onready var timer = $Timer

var dir
var start_pos_offset

func _ready():
	var angle = rotation
	if not rot_off_sprite_left:
		angle -= PI/2
	dir = -Vector2(cos(angle), sin(angle))
	
	relative_origin = get_node(relative_origin)
	start_pos_offset = global_transform.origin - relative_origin.global_transform.origin
	
	timer.wait_time = respawn_interval
	timer.start()

func _process(delta):
	transform.origin += dir*delta*speed
	rotate(deg2rad(rotation_speed*delta))

func _on_Timer_timeout():
	timer.start()
	transform.origin = relative_origin.global_transform.origin+start_pos_offset
