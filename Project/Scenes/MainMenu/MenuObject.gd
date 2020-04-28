extends Sprite

export (NodePath) var relative_origin

export var rot_off_sprite_left = false
export var speed = 50
export var rotation_speed = 0

var dir
var start_pos_offset

func _ready():
	var angle = rotation
	if not rot_off_sprite_left:
		angle -= PI/2
	dir = -Vector2(cos(angle), sin(angle))
	
	relative_origin = get_node(relative_origin)
	start_pos_offset = global_transform.origin - relative_origin.global_transform.origin
	
	get_node("VisibilityNotifier2D").connect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")

func _process(delta):
	transform.origin += dir*delta*speed
	rotate(deg2rad(rotation_speed*delta))

func _on_VisibilityNotifier2D_screen_exited():
	print(name + " exited")
	transform.origin = relative_origin.global_transform.origin+start_pos_offset
