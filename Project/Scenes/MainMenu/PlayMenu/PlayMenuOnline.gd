extends Control

onready var status = $VBox/VBoxContainer/HBoxContainer/Status
onready var btn_start = $VBox/Control/BtnStart
onready var msg_lab = $VBox/VBoxContainer/StatusContainer/Message
onready var anim = $VBox/VBoxContainer/HBoxContainer/AnimationPlayer

var ip = ""

var player_containers
var all_entries = {}

func _ready():
	player_containers = [
		get_node("VBox/PlayerSelect/Player1"),
		get_node("VBox/PlayerSelect/Player2"),
		get_node("VBox/PlayerSelect/Player3"),
		get_node("VBox/PlayerSelect/Player4")
	]
	
	Network.connect("update_connections", self, "_on_network_update")

func show():
	status.text = "Connecting..."
	visible = true
	btn_start.hide() # hide it as default

func _on_network_update(players):
	yield(get_tree().create_timer(0.25), "timeout")
	# show status
	var temp = Network.get_ip()
	ip = temp[0]
	var port_opened = temp[1]
	
	if Network.local_id == 1:
		# show start when we are the server and there are enough players
		if Network.connected_players.size() > 1: 	btn_start.show()
		else: 										btn_start.hide()
		
		status.text = "Hosting at: " + ip
		
		if not port_opened:
			msg_lab.text = "Port ("+str(Network.PORT)+") not opened automatically at: " + Network.public_ip
		else:
			msg_lab.text = "Local address: " + Network.get_local_ip()
	else:
		msg_lab.text = ""
		status.text = "Connected at: " + ip
	
	# show players
	var i = 0
	for id in players:
		if id == Network.local_id: 	player_containers[i].make_self(players[id]) 
		else: 						player_containers[i].make_other(players[id])
		i += 1
	
	# hide remaining slots
	for j in range(4-i):
		player_containers[i+j].remove_player()


func add_player(adding, pid):
	Global.players[int(pid)-1] = "-"

func make_bot(is_bot, pid):
	Global.players[int(pid)-1] = "@" if is_bot else ""

func get_player_entries(entries):
	for key in entries:
		all_entries[key] = entries[key]

func remove_duplicate(k):
	all_entries[k].value = null
	all_entries[k].set_text()

func _on_BtnStart_pressed():
	Settings.set_game_binds()
	Settings.save_settings()
	Network.start_game()
	#init_player_names()

#func init_player_names():
#	for i in range(4):
#		# check if its a bot or not playing
#		if Global.players[i] in ["@", "-"]:
#			# check if player also didnt call himself that
#			if !(names[i] in ["@", "-"]):
#				if Global.players[i] == "@":
#					names[i].text = "Bot " + str(i+1)
#		
#		var n = check_name(names[i].text)
#		if n != "":
#			Global.player_names[i] = n
#		else:
#			Global.player_names[i] = "Player "+str(i+1)

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

func _on_BtnDisconnect_pressed():
	for c in player_containers:
		c.remove_player()
	get_parent().close_online_menu()


func _on_Status_pressed():
	if ip != "":
		anim.play("copy")
		OS.clipboard = ip
