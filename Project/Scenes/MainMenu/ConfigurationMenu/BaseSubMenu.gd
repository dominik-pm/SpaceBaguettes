extends VBoxContainer

var all_entries = []

func _ready():
	for c in get_children():
		if c is ConfigBaseEntry:
			c.init(self)
			all_entries.push_back(c)

func value_changed(setting, value):
	Settings.set_setting("configuration", setting, value)

func load_last():
	for c in get_children():
		if c is ConfigBaseEntry:
			var value = Settings.get_setting("configuration", c.setting) 
			_set_value(c, value)

func load_default():
	for c in get_children():
		if c is ConfigBaseEntry:
			var value = Settings.get_setting("defaultConfiguration", c.setting)
			_set_value(c, value)

func _set_value(entry, value):
	# tell the entry the value
	entry.set_value(value)
