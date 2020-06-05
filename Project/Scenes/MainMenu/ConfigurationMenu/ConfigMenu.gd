extends VBoxContainer

func _ready():
	pass

func _on_LastBtn_pressed():
	for c in get_children():
		if c.has_method("load_last"):
			c.load_last()

func _on_DefaultBtn_pressed():
	for c in get_children():
		if c.has_method("load_default"):
			c.load_default()
