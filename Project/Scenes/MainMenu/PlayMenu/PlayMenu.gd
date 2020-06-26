extends Control

export (NodePath) var menu

onready var btn_start = $VBox/Control/BtnStart
onready var popup = $PopupDialog

var player_containers
var names
var all_entries = {}

var one_bot = false

func _ready():
	menu = get_node(menu)
	
	names = [
		get_node("VBox/PlayerSelect/Player1/PlayerNameInput"),
		get_node("VBox/PlayerSelect/Player2/PlayerNameInput"),
		get_node("VBox/PlayerSelect/Player3/PlayerNameInput"),
		get_node("VBox/PlayerSelect/Player4/PlayerNameInput")
	]
	player_containers = [
		get_node("VBox/PlayerSelect/Player1"),
		get_node("VBox/PlayerSelect/Player2"),
		get_node("VBox/PlayerSelect/Player3"),
		get_node("VBox/PlayerSelect/Player4")
	]
	
	for i in range(player_containers.size()):
		if Global.player_gp_ids[i] != "":
			player_containers[i].make_gamepad(true)
	
	if Global.is_mobile:
		for c in $VBox/PlayerSelect.get_children():
			c.get_node("Container/Keys").hide()

func show():
	visible = true
	btn_start.grab_focus()

func add_player(adding, pid):
	if adding:
		Global.players[int(pid)-1] = ""
	else:
		Global.players[int(pid)-1] = "-"

func make_bot(is_bot, pid):
	#Global.players[int(pid)-1] = "" if is_bot else ""
	
	# ONLY ONE BOT POSSIBLE ->
	if is_bot and not one_bot:
		Global.players[int(pid)-1] = "@"
		one_bot = true
	elif not is_bot:
		one_bot = false
		Global.players[int(pid)-1] = ""

func get_player_entries(entries):
	for key in entries:
		all_entries[key] = entries[key]

func remove_duplicate(k):
	all_entries[k].value = null
	all_entries[k].set_text()

func _on_BtnStart_pressed():
	init_player_names()
	menu.start_game()

func get_gp_id_for(pid):
	if Global.player_gp_ids[int(pid)-1] == "" and not popup.visible:
		print("Player"+pid+": getting controller id...")
		popup.get_gp_id_for(pid)
	else:
		Global.player_gp_ids[int(pid)-1] = ""
		player_containers[int(pid)-1].make_gamepad(false)

func set_gp_id_for(pid, gp_id):
	Global.player_gp_ids[int(pid)-1] = str(gp_id+1)
	player_containers[int(pid)-1].make_gamepad(true)

func _on_CancelBtn_pressed():
	popup.hide()
	btn_start.grab_focus()

func init_player_names():
	for i in range(4):
		# check if its a bot or not playing
		if Global.players[i] in ["@", "-"]:
			# check if player also didnt call himself that
			if !(names[i] in ["@", "-"]):
				if Global.players[i] == "@":
					names[i].text = "Bot " + str(i+1)
		
		var n = check_name(names[i].text)
		if n != "":
			Global.player_names[i] = n
		else:
			Global.player_names[i] = "Player "+str(i+1)

# returns "" if the name is not valid
func check_name(s : String):
	# an empty string is not valid
	if s == "":
		return ""
	elif s == "@":
		return ""
	elif s == "-":
		return ""
	# if the string is longer than 16 -> adjust it to 16 chars
	elif s.length() > 16:
		s = s.substr(0, 16)
	
	# return the string
	return s
