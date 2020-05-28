extends TextureRect

var color_normal = Color(0.745098, 0.243137, 0.247059, 1)
var color_hover = Color(0.243137, 0.556863, 0.745098, 1)

func _ready():
	self.self_modulate = color_normal
	
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")

func _on_mouse_entered():
	self.self_modulate = color_hover

func _on_mouse_exited():
	self.self_modulate = color_normal
