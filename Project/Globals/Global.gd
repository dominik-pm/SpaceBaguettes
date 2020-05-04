extends Node

var tilesize = 64

var icon_path = "res://Assets/Game/Player/Icons/"
var player_icon_paths = {
	"player_1": icon_path + "Player1.png",
	"player_2": icon_path + "Player2.png",
	"player_3": icon_path + "Player3.png",
	"player_4": icon_path + "Player4.png"
}

# -- GAME SETTINGS --
var player_count = 4

var player_maxhealth = 3
var player_shoot_delay = 1
var player_invincible_time = 3

var starting_explosion_size = 3
var bomb_explosion_time = 3
var bomb_explosion_duration = 2
var starting_bombs = 1
var starting_baguettes = 10
# -- --
