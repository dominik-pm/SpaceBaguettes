extends VBoxContainer

var all_entries = []

func _ready():
	var entry = Preloader.conf_item_entry
	
	for item in Items.drop_probabilities:
		var new_entry = entry.instance()
		add_child(new_entry)
		new_entry.init(item, self)
		all_entries.push_back(new_entry)

func drop_rate_changed(item, value):
	Items.drop_probabilities[item] = value
	Settings.set_setting("configuration", "Item"+str(item), value)

func load_last():
	for item in Items.drop_probabilities:
		var value = Settings.get_setting("configuration", "Item"+str(item)) 
		_set_value(item, value)

func load_default():
	for item in Items.drop_probabilities:
		var value = Settings.get_setting("defaultConfiguration", "Item"+str(item))
		_set_value(item, value)

func _set_value(item, value):
	# set drop probs
	Items.drop_probabilities[item] = value
	# tell the entry the value
	all_entries[item].set_value(value)
