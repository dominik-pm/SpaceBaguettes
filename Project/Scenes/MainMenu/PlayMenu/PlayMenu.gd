extends Control

export (NodePath) var menu

var names
var player_count = 4
var all_entries = {}
var players_34 = {
	"3": false,
	"4": false,
}

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
	players_34[pid] = adding
	
	if adding:
		player_count += 1
	else:
		player_count -= 1

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
		if i > 1:
			# if the player is not playing, set name to '@' and continue
			if not players_34[str(i+1)]:
				Global.player_names[i] = "-"
				continue
		
		# check if its a bot (idk how, maybe a button)
		# set Global.player_names[i] = "@"
		
		var n = check_name(names[i].text)
		if n != "":
			Global.player_names[i] = n
		else:
			Global.player_names[i] = "Player"+str(i+1)
	#print(Global.player_names)

# returns "" if the name is not valid
func check_name(s : String):
	# an empty string is not valid
	# a '@' or a '-' is also not valid
	if s == "":
		return ""
	# if the string is longer than 16 -> adjust it to 16 chars
	elif s.length() > 16:
		s = s.substr(0, 16)
	
	# return the string
	return s
