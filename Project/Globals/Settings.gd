# Stores, saves and loads game Settings in an ini-style file
extends Node

const SAVE_PATH = "res://config.cfg" # in debug
#const SAVE_PATH = "user://config.cfg" # on build

var config_file = ConfigFile.new()

var settings = {
	"bindings": {
		"1move_forward": 87,
		"1move_backward": 83,
		"1move_left": 65,
		"1move_right": 68,
		"1shoot": 70,
		"1set_bomb": 32,
		"2move_forward": 38,
		"2move_backward": 40,
		"2move_left": 37,
		"2move_right": 39,
		"2shoot": 189,
		"2set_bomb": 190,
		"3move_forward": "",
		"3move_backward": "",
		"3move_left": "",
		"3move_right": "",
		"3shoot": "",
		"3set_bomb": "",
		"4move_forward": "",
		"4move_backward": "",
		"4move_left": "",
		"4move_right": "",
		"4shoot": "",
		"4set_bomb": ""
	},
	"video": {
		"fullscreen": false
	},
	"audio": {
		"master_volume": 50.0,
		"sound_volume": 50.0,
		"music_volume": 50.0
	}
}
 
func _ready():
	#save_settings()
	load_settings()

func set_game_binds():
	for key in settings["bindings"]:
		var value = settings["bindings"][key]
		
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key, actionlist[0])
		
		if str(value) != "":
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)
			InputMap.action_add_event(key, new_key)

func save_settings():
	for section in settings.keys():
		for key in settings[section]:
			config_file.set_value(section, key, settings[section][key])
			#if settings[section][key] != "":
			#	config_file.set_value(section, key, settings[section][key])
			#else:
			#	config_file.set_value(section, key, "")
	
	config_file.save(SAVE_PATH)
	print("successfully saved settings")

func load_settings():
	# Open the file
	var error = config_file.load(SAVE_PATH)
	
	# Check if it opened
	if error != OK:
		print("Failed loading settings file. Error code %s" % error)
		print("Creating a new one...")
		save_settings()
		return
	
	# Retrieve the values and store them in settings
	for section in settings.keys():
		for key in settings[section]:
			var value = config_file.get_value(section, key, "")
			settings[section][key] = value
			#if str(value) != "":
			#	settings[section][key] = value
			#else:
			#	settings[section][key] = ""
	
	print("successfully loaded settings")

func get_setting(category, key):
	return settings[category][key]

func set_setting(category, key, value):
	settings[category][key] = value
