extends VBoxContainer

onready var container = $Container
onready var name_input = $PlayerName

onready var keys = $Container/Keys
onready var bot_icon = $Container/BotIcon

#var btn_add = null
var btn_bot = null
var btn_rem = null

var is_bot = false

export (String) var pid
export (NodePath) var menu

func _ready():
	menu = get_node(menu)
	remove_player()
	#make_bot(is_bot)
	#if int(pid) > 2:
		#btn_add = get_node("BtnAdd")
		#btn_bot = get_node("Container/Icons/HBoxContainer/BtnMakeBot")
		#remove_player()

func remove_player():
	#menu.add_player(false, pid)
	container.hide()
	name_input.hide()
	#btn_add.show()
	#btn_add.grab_focus()


# for network
func make_self(n):
	container.show()
	name_input.show()
	
	name_input.text = str(n)
	keys.show()
	bot_icon.hide()
func make_other(n):
	container.show()
	name_input.show()
	
	name_input.text = str(n)
	keys.hide()
	bot_icon.show()

#func make_bot(is_bot):
#	menu.make_bot(is_bot, pid)
#	name_input.visible = !is_bot
#	keys.visible = !is_bot
#	bot_icon.visible = is_bot

func add_player():
	#menu.add_player(true, pid)
	container.show()
	name_input.show()
	#btn_add.hide()
	#btn_rem.grab_focus()

func _on_BtnMakeBot_pressed():
	is_bot = !is_bot
	#make_bot(is_bot)

func _on_BtnAdd_pressed():
	add_player()
