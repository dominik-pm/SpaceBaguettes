extends TextureButton

export var player_id = "1"
export (NodePath) var menu

func _ready():
	connect("pressed", self, "_on_BtnMakeController_pressed")
	menu = get_node(menu)

func _on_BtnMakeController_pressed():
	menu._on_MakeGPPressed(player_id)
