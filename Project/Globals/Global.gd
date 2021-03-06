extends Node

var tilesize = 64

var icon_path = "res://Assets/Game/Player/Icons/"
var player_icon_paths = {
	"player1": icon_path + "Player1.png",
	"player2": icon_path + "Player2.png",
	"player3": icon_path + "Player3.png",
	"player4": icon_path + "Player4.png"
}

# '-' means not playing; '@' means is bot
var players = ["", "", "", ""]
var player_names = ["", "", "", ""]
var player_gp_ids = ["", "", "", ""]

# -- GAME SETTINGS --
# game
var crate_item_drop_chance = 30.0
var sudden_death_spawn_rate = 5.0

# player
#var player_count = 2 # changed in the menu
var player_maxhealth = 3
var player_shoot_delay = 0.8
var player_invincible_time = 3
var player_max_speed_buffs = 5

# items
var speed_buff = 20
var starting_bombs = 1
var starting_explosion_range = 1
var starting_explosion_strength = 1
var starting_baguettes = 3

# bombs
var bomb_explosion_time = 2.5
var bomb_explosion_duration = 1
# -- --

var is_mobile = false

func _ready():
	if OS.has_touchscreen_ui_hint():
		is_mobile = true
