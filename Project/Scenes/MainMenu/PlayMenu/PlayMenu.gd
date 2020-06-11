extends Control

export (NodePath) var menu

var names
var all_entries = {}

func _ready():
	menu = get_node(menu)
	
	names = [
		get_node("VBox/PlayerSelect/Player1/PlayerNameInput"),
		get_node("VBox/PlayerSelect/Player2/PlayerNameInput"),
		get_node("VBox/PlayerSelect/Player3/PlayerNameInput"),
		get_node("VBox/PlayerSelect/Player4/PlayerNameInput")
	]
	
	$VBox/Control/BtnStart.grab_focus()

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
	init_player_names()
	menu.start_game()

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
