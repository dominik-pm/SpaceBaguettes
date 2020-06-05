extends Node2D

export (NodePath) var pause_menu_path = null
var pause_menu = null
export (NodePath) var game_summary_path = null
var game_summary = null

export (NodePath) var gui_path = null
var gui = null

onready var cam = $Camera
onready var pos1 = $Position1
onready var pos2 = $Position2
onready var crates = $Container/Crates
onready var spawns = $PlayerSpawns.get_children()
onready var container = $Container
onready var player_container = $Container
onready var settings_menu = $Foreground/SettingsMenu

# get those by code
var map_size_x = 19
var map_size_y = 15

var cellsize

var game_over = false
var players_alive = 4

func _ready():
	$Music.play()
	$Click.stream.loop = false
	$StartGame.stream.loop = false
	
	pause_menu = get_node(pause_menu_path)
	game_summary = get_node(game_summary_path)
	gui = get_node(gui_path)
	
	pause_menu.hide()
	settings_menu.hide()
	game_summary.hide() 
	gui.init_player_gui()
	
	cellsize = crates.cell_size
	
	#cam.limit_left = pos1.transform.origin.x
	#cam.limit_top = pos1.transform.origin.y
	#cam.limit_right = pos2.transform.origin.x
	#cam.limit_bottom = pos2.transform.origin.y
	
	players_alive = init_players()
	
	$StartCountdown.start_countdown()
	$StartCountdown.connect("countdown_finished", self, "_on_start_cntdwn_finished")

func _on_start_cntdwn_finished():
	$StartGame.play()
	# tell the players that the game started
	for c in container.get_children():
		if c is Player:
			c.start()

func _input(event):
	if event.is_action_pressed("toggle_pause_menu") and not game_summary.visible:
		if not settings_menu.visible:
			pause_menu.visible = !pause_menu.visible
			get_tree().paused = pause_menu.visible
			$Foreground/Menu/CenterContainer/VBoxContainer/BtnResume.grab_focus()
		else:
			settings_menu.hide()
			$Foreground/Menu/CenterContainer/VBoxContainer/BtnSettings.grab_focus()

func init_players():
	var cnt = 0
	for i in 4:
		# player is not playing, when playername is '@'
		if Global.player_names[i] != "@":
			cnt += 1
			
			var p = spawns[i].global_transform.origin
			var t = crates.world_to_map(p)
			var pos = crates.map_to_world(t) + Vector2(32, 32)
			var player = Preloader.player.instance()
			player_container.add_child(player)
			var dir = Vector2(1, 0)
			if i%2 != 0:
				dir = Vector2(-1, 0)
			player.init(pos, i+1, dir, self)
	return cnt

# -- player called -->
# to update the players items, health,..
func update_info(player : int, item, value):
	if gui != null:
		gui.update_info(player, item, value)
func update_current_bombs(player : int, cur_bombs):
	if gui != null:
		gui.update_current_bombs(player, cur_bombs)
func player_hit(player : int):
	gui.player_hit(player)
	cam.request_camera_shake(0.5)
func player_died(player : int):
	if not game_over:
		players_alive -= 1
		cam.request_camera_shake(1.0)
		gui.player_died(player) # tell the gui
		
		# check only one player is alive -> game over
		if players_alive <= 1:
			game_over = true
			
			# show the game summary
			var winner_id = _get_winner() # also hides the winner
			game_summary.show_summary(winner_id)
			
			# animation and sound
			$GameOver.play()
			$AnimationPlayer.play("GameOver") # also mutes music
func get_tile_pos_center(p):
	var pos = crates.world_to_map(p)
	pos = crates.map_to_world(pos) + (cellsize/2)
	return pos
func place_bomb(player, pos, e_range, e_strenth):
	# convert the pos into a coordinate of the grid
	var coord = crates.world_to_map(pos)
	# convert it back to a world position to get the top center of it
	var p = crates.map_to_world(coord)
	p.x = p.x + (cellsize.x/2)
	
	var b = Preloader.bomb.instance()
	container.add_child(b)
	b.init(self, player, e_range, e_strenth)
	b.global_transform.origin = p
func add_node(node):
	container.add_child(node)
# <-- player called --

func _get_winner():
	var winner = null
	for c in container.get_children():
		if c is Player:
			var player = c
			if player.is_alive:
				winner = int(player.pid)
	return winner

# bullet called
func bullet_hit(pos, dir):
	# get the tile
	var tile = crates.world_to_map(pos+(dir*(cellsize/2)))
	
	# check if it is a crate
	var tileset = crates.get_tileset()
	var idx = crates.get_cellv(tile)
	if idx != -1:
		var tilename = tileset.tile_get_name(idx)
		if tilename == "wooden_crate":
			# remove the crate
			_destroy_crate(tile)

func _destroy_crate(tile):
	var pos = crates.map_to_world(tile) + (cellsize/2)
	
	# remove the tile in the tilemap
	crates.set_cellv(tile, -1)
	
	# create destroy effect
	var e = Preloader.effect_pop.instance()
	container.add_child(e)
	e.global_transform.origin = pos
	
	# with a certain probability, drop an item
	randomize()
	if rand_range(0, 100) < Global.crate_item_drop_chance:
		_spawn_item(pos)
func _spawn_item(pos):
	var i = Preloader.item.instance()
	container.add_child(i)
	i.global_transform.origin = pos
	i.init(_get_random_item())
func _get_random_item():
	randomize()
	
	# get the item pool
	var items = []
	for item in Items.drop_probabilities:
		for i in range(Items.drop_probabilities[item]):
			items.push_back(item)
	
	# return a random item from the pool
	var rand_idx = floor(rand_range(0, items.size()))
	return items[rand_idx]

# bomb called
func explode(p, r, s):
	# get the coordinates of the tile the explosion is on
	var coord = crates.world_to_map(p)
	
	# destroy the crates and get how far the explosion got in each direction
	var directions = [0, 0, 0, 0]
	directions[0] = _destroy_line(coord, Vector2(0,-1), r, s)
	directions[1] = _destroy_line(coord, Vector2(1,0), r, s)
	directions[2] = _destroy_line(coord, Vector2(0,1), r, s)
	directions[3] = _destroy_line(coord, Vector2(-1,0), r, s)
	
	# get the position of the center of the tile
	var pos = crates.map_to_world(coord) + (cellsize/2)
	
	_create_explosion(pos, directions)
# destroy the first wooden crate found in a line 
# from the coord_start into the dir with a depth of r
func _destroy_line(coord_start, dir, r, s):
	var tileset = crates.get_tileset()
	var cnt = 0
	
	for i in range(1, r+1):
		# calculate the corrdinates of the current block 
		var block_coordinates = coord_start+(dir*i)
		
		# check if there is actually a tile (returns -1 if there is none)
		var cell_index = crates.get_cellv(block_coordinates)
		if cell_index != -1:
			var tiletype = tileset.tile_get_name(cell_index)
			
			# check if that tile can be destroyed (a wooden crate)
			if tiletype == "wooden_crate":
				cnt += 1
				# remote the crate
				_destroy_crate(block_coordinates)
				# return when there are as many block destroyed as the explosion strength 
				if cnt >= s:
					return i # only remove the first crate
			else:
				# it is a wall or a metall crate so this is the end of the line
				return i-1
	# it didnt hit anything
	return r
# to instance the explosion effect
func _create_explosion(p, dirs):
	var e = Preloader.explosion.instance()
	container.add_child(e)
	e.init(p, dirs)


# Menu Stuff

func _on_BtnResume_pressed():
	$Click.play()
	get_tree().paused = false
	pause_menu.hide()

func _on_BtnRestart_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Game/Game.tscn")

func _on_BtnSettings_pressed():
	$Click.play()
	settings_menu.show()
	$Foreground/SettingsMenu/Control/HBoxContainer/BtnCloseSettings.grab_focus()

func _on_BtnCloseSettings_pressed():
	$Click.play()
	settings_menu.hide()
	$Foreground/Menu/CenterContainer/VBoxContainer/BtnSettings.grab_focus()

func _on_BtnMenu_pressed():
	$Click.play()
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_BtnQuit_pressed():
	get_tree().quit()

func _on_BtnPlay_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Game/Game.tscn")
