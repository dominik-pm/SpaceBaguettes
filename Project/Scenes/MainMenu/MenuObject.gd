extends Sprite

export (NodePath) var relative_origin

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
	get_node("VisibilityNotifier2D").connect("viewport_exited", self, "_on_VisibilityNotifier2D_viewport_exited")

func _process(delta):
	transform.origin += dir*delta*speed
	rotate(deg2rad(rotation_speed*delta))

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	# does not work correctly and also fires when scene is changed :(
	print(name + " exited")
	timer.start()

func _on_Timer_timeout():
	transform.origin = relative_origin.global_transform.origin+start_pos_offset
