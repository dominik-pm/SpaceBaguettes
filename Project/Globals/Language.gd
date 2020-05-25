extends Node

signal language_changed

enum languages {
	ENGLISH,
	GERMAN,
   FRENCH
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
	"playerdesc": "The player can move in any direction, place bombs, fire baguettes and also collect items.",
	"bombs": "Bomb",
	"bombsdesc": "Placed bombs explode after a short time.\nThe Explosion fires in every direction and depends on the items of the player.",
	"baguettes": "Baguette",
	"baguettesdesc": "The player has a certain amount of baguettes, that can be fired.\nWhen a baguette hits a bomb, it explodes.\nWhen it hits a player, he loses one health point.",
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
	"restart": "Restart",
	"settings": "Settings",
	"play": "Play",
	"menu": "Menu",
	"quit": "Quit",
	# Game
	"winnermessage": "won!"
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
	"playerdesc": "Der Spieler kann sich in jede Richtung bewegen, Bomben legen, Baguettes schießen und Items aufsammeln",
	"bombs": "Bombe",
	"bombsdesc": "Gelegte Bomben explodieren nach einer kurzen Zeit.\nDie Explosion wirkt sich in jede Richtung aus und hängt von den Items des Spielers ab.",
	"baguettes": "Baguette",
	"baguettesdesc": "Der Spieler hat eine begrenzte Anzahl von Baguettes, welche er schießen kann.\nTrifft ein Baguette auf eine Bombe, explodiert diese sofort.\nTrifft es einen Spieler, verliert dieser ein Leben.",
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
	"restart": "Neustart",
	"settings": "Einstellungen",
	"play": "Spielen",
	"menu": "Menü",
	"quit": "Verlassen",
	# Game
	"winnermessage": "hat gewonnen!"
}

var lang_french = {
	# Settings Menu
	"language": "langue",
	"graphics": "graphique",
	"fullscreen": "plein écran",
	"audio": "l'audio",
	"master": "maître",
	"sound": "du son",
	"music": "la musique",
	# Help Menu
	"player": "joueur",
	"playerdesc": "Le joueur peut se déplacer dans n'importe quelle direction, placer des bombes, tirer des baguettes et collecter des objets",
	"bombs": "bombe",
	"bombsdesc": "Les bombes placées explosent peu de temps après.\nL'explosion affecte dans toutes les directions et dépend des objets du joueur.",
	"baguettes": "baguette",
	"baguettesdesc": "Le joueur dispose d'un nombre limité de baguettes qu'il peut tirer.\nSi une baguette touche une bombe, elle explose immédiatement.\nSi un joueur est touché, il perd une vie.",
	"items": "items",
	"extrahealth": "Le joueur obtient une autre vie",
	"extrabomb": "Une autre bombe peut être placée simultanément",
	"extrabaguette": "Le joueur reçoit une autre baguette",
	"fastboots": "La vitesse du joueur est augmentée",
	"bombrange": "La portée de la bombe augmente",
	"bombexplosion": "La bombe peut détruire une autre caisse en même temps",
	"bombmoving": "Les bombes peuvent être déplacées plus rapidement",
	# Menu Buttons
	"resume": "continuer",
	"restart": "redémarrer",
	"settings": "paramètres",
	"play": "jouer",
	"menu": "menu",
	"quit": "quittez",
	# Game
	"winnermessage": "a gagné!"
}

var current

func _ready():
	current = Settings.get_setting("general", "language")

func change_language(lang):
	current = lang
	Settings.set_setting("general", "language", current)
	emit_signal("language_changed", current)
