extends Node

signal language_changed

enum languages {
	ENGLISH,
	GERMAN
}

var lang_english = {
	# Settings Menu
	"language": "Language",
	"graphics": "Graphics",
	"fullscreen": "Fullscreen",
	"audio": "Audio",
	"master": "Master",
	"sound": "Sound",
	"music": "Music",
	# Help Menu
	"player": "Player",
	"playerdesc": "The player is a player",
	"bombs": "Bomb",
	"bombsdesc": "The bomb is a bomb",
	"baguettes": "Baguette",
	"baguettesdesc": "The baguette is a baguette",
	"items": "Items",
	"extrahealth": "The player will get one more live",
	"extrabomb": "The player will be able to place more bombs at the same time",
	"extrabaguette": "The player will get another baguette",
	"fastboots": "The player's speed will be faster",
	"bombrange": "The bomb will get a bigger range",
	"bombexplosion": "The bomb will destroy more crates in a line",
	"bombmoving": "Bombs will be moved faster",
	# Menu Buttons
	"resume": "Resume",
	"play": "Play",
	"menu": "Menu",
	"quit": "Quit"
}
var lang_german = {
	# Settings Menu
	"language": "Sprache",
	"graphics": "Grafik",
	"fullscreen": "Vollbild",
	"audio": "Audio",
	"master": "Master",
	"sound": "Sound",
	"music": "Musik",
	# Help Menu
	"player": "Spieler",
	"playerdesc": "Der Spieler ist ein Spieler",
	"bombs": "Bombe",
	"bombsdesc": "Die bombe ist eine Bombe",
	"baguettes": "Baguette",
	"baguettesdesc": "Das Baguette ist ein Baguette",
	"items": "Items",
	"extrahealth": "Der Spieler erhält ein weiteres Leben",
	"extrabomb": "Eine weitere Bombe kann gleichzeitig platziert werden",
	"extrabaguette": "Der Spieler erhält ein weiteres Baguette",
	"fastboots": "Die Spielergeschwindigkeit wird erhöht",
	"bombrange": "Die Reichweite der Bombe erhöht sich",
	"bombexplosion": "Die Bombe kann eine weitere Kiste gleichzeitig zerstören",
	"bombmoving": "Bomben lassen sich schneller verschieben",
	# Menu Buttons
	"resume": "Fortsetzen",
	"play": "Spielen",
	"menu": "Menü",
	"quit": "Verlassen"
}


var current

func _ready():
	current = Settings.get_setting("general", "language")

func change_language(lang):
	current = lang
	Settings.set_setting("general", "language", current)
	emit_signal("language_changed", current)
