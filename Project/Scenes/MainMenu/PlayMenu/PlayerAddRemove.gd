extends VBoxContainer

onready var container = $Container
onready var name_input = $PlayerNameInput

onready var btn_add = $BtnAdd

export (String) var pid
export (NodePath) var menu

func _ready():
	menu = get_node(menu)
	remove_player()

func remove_player():
	menu.add_player(false, pid)
	container.hide()
	name_input.hide()
	btn_add.show()

func add_player():
	menu.add_player(true, pid)
	container.show()
	name_input.show()
	btn_add.hide()

func _on_BtnRemove_pressed():
	remove_player()

func _on_BtnAdd_pressed():
	add_player()
