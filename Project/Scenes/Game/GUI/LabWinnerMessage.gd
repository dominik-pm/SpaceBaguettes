extends "res://Scenes/TextLabel.gd"

func set_winner(n):
	_on_language_changed(Language.current)
	text = str(n) + " " + text
