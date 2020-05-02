extends HBoxContainer

onready var icons = $Icons
onready var keys = $Keys

onready var btn_add = $BtnAdd

export (NodePath) var menu

func _ready():
	menu = get_node(menu)
	remove_player()

func remove_player():
	menu.add_player(false)
	icons.hide()
	keys.hide()
	btn_add.show()

func add_player():
	menu.add_player(true)
	icons.show()
	keys.show()
	btn_add.hide()

func _on_BtnRemove_pressed():
	remove_player()

func _on_BtnAdd_pressed():
	add_player()
