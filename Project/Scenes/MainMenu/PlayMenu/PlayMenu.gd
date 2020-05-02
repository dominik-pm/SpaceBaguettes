extends Control

export (NodePath) var menu

var player_count = 4

var all_entries = {}

func _ready():
	menu = get_node(menu)

func add_player(adding):
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
	menu.start_game(player_count)
