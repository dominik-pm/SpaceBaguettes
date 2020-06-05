extends HBoxContainer

onready var icon = $Icon
onready var sldr = $DropRate

var change_rate = true

var item
var menu

func init(i, m):
	item = i
	menu = m
	
	icon.texture = load(Items.icons[item])
	
	set_value(Items.drop_probabilities[item])

func set_value(v):
	# set it to false to not count the next value change signal as a user signal
	change_rate = false
	sldr.value = v

func _on_DropRate_value_changed(value):
	if change_rate:
		menu.drop_rate_changed(item, value)
	else:
		change_rate = true
