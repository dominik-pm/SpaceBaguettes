extends Node

var tilesize = 64

var icon_path = "res://Assets/Game/Player/Icons/"
var player_icon_paths = {
	"player1": icon_path + "Player1.png",
	"player2": icon_path + "Player2.png",
	"player3": icon_path + "Player3.png",
	"player4": icon_path + "Player4.png"
}

# -- GAME SETTINGS --
var player_count = 1

var player_maxhealth = 3
var player_shoot_delay = 1
var player_invincible_time = 3

var starting_explosion_range = 3
var bomb_explosion_time = 3
var bomb_explosion_duration = 2
var starting_bombs = 1
var starting_baguettes = 10
# -- --
