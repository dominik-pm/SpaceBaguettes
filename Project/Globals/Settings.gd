# Stores, saves and loads game Settings in an ini-style file
extends Node

signal settings_loaded

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
		"2move_forward": 16777232,
		"2move_backward": 16777234,
		"2move_left": 16777231,
		"2move_right": 16777233,
		"2shoot": 45,
		"2set_bomb": 46,
		"3move_forward": 73,
		"3move_backward": 75,
		"3move_left": 74,
		"3move_right": 76,
		"3shoot": 72,
		"3set_bomb": 85,
		"4move_forward": 16777358,
		"4move_backward": 16777355,
		"4move_left": 16777354,
		"4move_right": 16777356,
		"4shoot": 16777359,
		"4set_bomb": 16777353
	},
	"general": {
		"language": 0
	},
	"video": {
		"fullscreen": false
	},
	"audio": {
		"master_volume": 50.0,
		"sound_volume": 50.0,
		"music_volume": 50.0
	},
	"defaultConfiguration": {
		"ItemDropChance": 30,
		"Item0": 1,
		"Item1": 3,
		"Item2": 3,
		"Item3": 0,
		"Item4": 2,
		"Item5": 1,
		"Item6": 2,
		"MaxHealth": 3,
		"Baguettes": 3,
		"Bombs": 1
	},
	"configuration": {
		"ItemDropChance": 30,
		"Item0": 1,
		"Item1": 3,
		"Item2": 3,
		"Item3": 0,
		"Item4": 2,
		"Item5": 1,
		"Item6": 2,
		"MaxHealth": 3,
		"Baguettes": 3,
		"Bombs": 1
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
		
		if str(value) != "" and value != null:
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)
			InputMap.action_add_event(key, new_key)
		else:
			#print("key is null")
			for action in actionlist:
				if action is InputEventJoypadButton:
					pass # dont remove controller motion input
				elif action is InputEventJoypadMotion:
					pass # dont remove controller motion input
				else:
					# removing key (was set to null from user)
					InputMap.action_erase_event(key, actionlist[action])

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
			
			# if there is no value set, save a new config file
			if str(value) == "":
				save_settings()
				return
			
			settings[section][key] = value
			
			#if str(value) != "":
			#	settings[section][key] = value
			#else:
			#	settings[section][key] = ""
	
	emit_signal("settings_loaded")

func get_setting(category, key):
	return settings[category][key]

func set_setting(category, key, value):
	settings[category][key] = value
