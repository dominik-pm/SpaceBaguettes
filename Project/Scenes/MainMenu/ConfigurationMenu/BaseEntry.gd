extends HBoxContainer

class_name ConfigBaseEntry

onready var input = $Input

export var setting = "MaxHealth"

var change_rate = true
var menu

func _ready():
	input.connect("value_changed", self, "_on_input_value_changed")

func init(m):
	menu = m
	
	var v = Settings.get_setting("defaultConfiguration", setting)
	
	set_value(v)

# overrite in child script
func change_variable(value = 0):
	 pass

func set_value(v):
	change_variable(v)
	
	# set it to false to not count the next value change signal as a user signal
	change_rate = false
	
	input.value = v
	
	change_rate = true


func _on_input_value_changed(v):
	if change_rate:
		change_variable(v)
		menu.value_changed(setting, v)
