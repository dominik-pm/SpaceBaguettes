extends TextureRect

var color_normal = Color(0.745098, 0.243137, 0.247059, 1)
var color_focus = Color(0.243137, 0.556863, 0.745098, 1)
var color_hover = Color(0.392157, 0.670588, 0.909804, 1)

var in_focus = false

func _ready():
	self.self_modulate = color_normal
	
	self.connect("mouse_entered", self, "_on_mouse_entered")
	self.connect("mouse_exited", self, "_on_mouse_exited")
	
	get_parent().connect("focus_entered", self, "_on_focus_entered")
	get_parent().connect("focus_exited", self, "_on_focus_exited")

func _on_mouse_entered():
	self.self_modulate = color_hover

func _on_mouse_exited():
	if not in_focus:
		self.self_modulate = color_normal
	else:
		self.self_modulate = color_focus

func _on_focus_entered():
	in_focus = true
	self.self_modulate = color_focus

func _on_focus_exited():
	in_focus = false
	self.self_modulate = color_normal
