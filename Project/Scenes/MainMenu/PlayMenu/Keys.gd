extends GridContainer

export (String) var player_id = "1"
export (NodePath) var menu

var keybind_entry = preload("res://Scenes/MainMenu/PlayMenu/KeybindInputEntry.tscn")

var all_player_binds
var player_keybinds = {}
var entries = {}

func _ready():
	menu = get_node(menu)
	
	# find all keybinds for that player
	all_player_binds = Settings.settings["bindings"]
	for key in all_player_binds:
		if key.substr(0, 1) == player_id:
			player_keybinds[key] = all_player_binds[key]
	
	var index = 0
	var all_containers = [$Forward, $Back, $Left, $Right, $Shoot, $Bomb]
	
	# init all keybind buttons
	for key in player_keybinds:
		var value = player_keybinds[key]
		if str(value) == "":
			value = null
		
		var cur_entry
		if all_containers[index].get_child_count() == 0:
			# create new keybind entry
			cur_entry = keybind_entry.instance()
			all_containers[index].add_child(cur_entry)
		else:
			# get existing node
			if all_containers[index].get_child_count() == 1:
				cur_entry = all_containers[index].get_child(0)
			else:
				cur_entry = all_containers[index].get_child(1)
		index += 1
		cur_entry.init(key, value, self)
		entries[key] = cur_entry
	
	# tell the menu all entries
	menu.get_player_entries(entries)

func change_bind(key, value):
	# check if the value is valid
	if OS.get_scancode_string(value) == "Escape":
		entries[key].value = null
	else:
		# check if it is not a duplicate key
		for k in all_player_binds.keys():
			if str(all_player_binds[k]) != "":
				if k != key and value != null and all_player_binds[k] == value:
					# it is a duplicate
					Settings.set_setting("bindings", k, null)
					menu.remove_duplicate(k)
		Settings.set_setting("bindings", key, value)
