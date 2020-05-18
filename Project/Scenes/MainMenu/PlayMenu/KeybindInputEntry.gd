extends Control

var key
var value
var menu

onready var button = $KeyInputButton

var waiting_input = false

func _ready():
	button.connect("pressed", self, "_on_KeyInputButton_pressed")

func init(k, v, m):
	key = k
	value = v
	set_text()
	menu = m

func _input(event):
	if waiting_input:
		# Only keyboard buttons are currently supported
		if event is InputEventKey:
			value = event.scancode
			menu.change_bind(key, value)
			set_text()
		if event is InputEventMouseButton:
			set_text()

func set_text():
	if value != null:
		var v = OS.get_scancode_string(value)
		match v:
			"Down": v = "DN"
			"Left": v = "LT"
			"Right":v = "RT"
			"Up":   v = "UP"
			"Period":v= "."
			"Minus":v = "-"
			"Comma":v = ","
			"Shift": v= "Shft"
			"Control": v = "Ctl"
			"QuoteLeft": v = "Ö"
			"Semicolon": v = "Ü"
			"Apostrophe":v = "Ä"
			_:
				if v.length() > 3:
					if v[2] == " ":
						v[2] = v[3]
					v = v.substr(0, 3)
		
		button.text = v
	else:
		button.text = "| |"
	button.pressed = false
	waiting_input = false

func _on_KeyInputButton_pressed():
	if not waiting_input:
		button.text = "..."
		waiting_input = true
