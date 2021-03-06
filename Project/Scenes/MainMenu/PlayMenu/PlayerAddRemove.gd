extends VBoxContainer

onready var container = $Container
onready var name_input = $PlayerNameInput

onready var keys = $Container/Keys
var bot_icon = null

var btn_add = null
var btn_bot = null
var btn_rem = null

var is_bot = false

export (String) var pid
export (NodePath) var menu

onready var gp_controls = $Container/GamePadControls

func _ready():
	menu = get_node(menu)
	
	if pid != "1":
		bot_icon = get_node("Container/BotIcon")
		
		if Global.is_mobile:
			is_bot = true
		
		make_bot(is_bot)
	
	if int(pid) > 1:
		btn_bot = get_node("Container/Icons/HBoxContainer/BtnMakeBot")
	if int(pid) > 2:
		btn_add = get_node("BtnAdd")
		btn_rem = get_node("Container/Icons/HBoxContainer/BtnRemove")
		remove_player()
	
	gp_controls.hide()
	

func remove_player():
	menu.add_player(false, pid)
	container.hide()
	name_input.hide()
	btn_add.show()
	btn_add.grab_focus()

func make_gamepad(is_gp):
	keys.visible = !is_gp
	gp_controls.visible = is_gp

func make_bot(is_bot):
	menu.make_bot(is_bot, pid)
	name_input.visible = !is_bot
	keys.visible = !is_bot
	if bot_icon != null:
		bot_icon.visible = is_bot

func add_player():
	menu.add_player(true, pid)
	container.show()
	name_input.show()
	btn_add.hide()
	btn_rem.grab_focus()
	if Global.is_mobile:
		make_bot(true)

func _on_gp_pressed():
	if not is_bot:
		menu.get_gp_id_for(pid)

func _on_BtnRemove_pressed():
	remove_player()

func _on_BtnMakeBot_pressed():
	if not Global.is_mobile:
		if is_bot or not menu.one_bot: # ONLY ONE BOT POSSIBLE
			is_bot = !is_bot
			make_bot(is_bot)

func _on_BtnAdd_pressed():
	add_player()
