extends Camera2D

export (NodePath) var rocket_window

func _ready():
	rocket_window = get_node(rocket_window)

func _process(delta):
	transform.origin.y -= delta*20

func zoom_into(object, z):
	global_transform.origin = object.global_transform.origin
	zoom = Vector2(z, z)
