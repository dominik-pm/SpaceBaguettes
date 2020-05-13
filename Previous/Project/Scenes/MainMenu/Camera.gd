extends Camera2D

export (NodePath) var rocket_window
export var speed = 20

func _ready():
	rocket_window = get_node(rocket_window)

func _process(delta):
	transform.origin.y -= delta*speed

func zoom_into(object, z):
	global_transform.origin = object.global_transform.origin
	zoom = Vector2(z, z)
