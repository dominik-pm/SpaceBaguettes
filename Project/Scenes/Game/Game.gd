extends Node2D

export (NodePath) var gui_path = null
var gui = null

onready var pos1 = $Position1
onready var pos2 = $Position2
onready var crates = $Container/Crates
onready var spawns = $PlayerSpawns.get_children()
onready var container = $Container
onready var player_container = $Container

# get those by code
var map_size_x = 19
var map_size_y = 15

var cellsize

var game_over = false
var players_alive = 4

func _ready():
	if gui_path != null:
		gui = get_node(gui_path)
	
	cellsize = crates.cell_size
	
	var cam = $Camera
	#cam.limit_left = pos1.transform.origin.x
	#cam.limit_top = pos1.transform.origin.y
	#cam.limit_right = pos2.transform.origin.x
	#cam.limit_bottom = pos2.transform.origin.y
	
	players_alive = Global.player_count
	init_players(players_alive)

func init_players(cnt):
	for i in cnt:
		var p = spawns[i].global_transform.origin
		var t = crates.world_to_map(p)
		var pos = crates.map_to_world(t) + Vector2(32, 32)
		var player = Preloader.player.instance()
		player_container.add_child(player)
		var dir = Vector2(1, 0)
		if i%2 != 0:
			dir = Vector2(-1, 0)
		player.init(pos, i+1, dir)

# -- player called -->
func update_info(player : int, item, value):
	if gui != null:
		gui.update_info(player, item, value)
func player_died(player : int):
	players_alive -= 1
	if players_alive <= 1:
		game_over = true
		print("game over")
		# todo: 
		# 1 get winning player
		# 2 
	if gui != null:
		gui.remove_player(player)
func get_shoot_pos(p):
	var pos = crates.world_to_map(p)
	pos = crates.map_to_world(pos) + (cellsize/2)
	return pos
func place_bomb(player, pos, s):
	# convert the pos into a coordinate of the grid
	var coord = crates.world_to_map(pos)
	# convert it back to a world position to get the top center of it
	var p = crates.map_to_world(coord)
	p.x = p.x + (cellsize.x/2)
	
	var b = Preloader.bomb.instance()
	container.add_child(b)
	b.init(self, player, s)
	b.global_transform.origin = p
func add_node(node):
	container.add_child(node)
# <-- player called --

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
	
	# spawn item
	var i = Preloader.item.instance()
	container.add_child(i)
	i.global_transform.origin = pos
	i.init(Items.MOREBOMBS)

# bomb called
func explode(p, r):
	# get the coordinates of the tile the explosion is on
	var coord = crates.world_to_map(p)
	
	# destroy the crates and get how far the explosion got in each direction
	var directions = [0, 0, 0, 0]
	directions[0] = _destroy_line(coord, Vector2(0,-1), r)
	directions[1] = _destroy_line(coord, Vector2(1,0), r)
	directions[2] = _destroy_line(coord, Vector2(0,1), r)
	directions[3] = _destroy_line(coord, Vector2(-1,0), r)
	
	# get the position of the center of the tile
	var pos = crates.map_to_world(coord) + (cellsize/2)
	
	_create_explosion(pos, directions)
# destroy the first wooden crate found in a line 
# from the coord_start into the dir with a depth of r
func _destroy_line(coord_start, dir, r):
	var tileset = crates.get_tileset()
	
	for i in range(1, r+1):
		# calculate the corrdinates of the current block 
		var block_coordinates = coord_start+(dir*i)
		
		# check if there is actually a tile (returns -1 if there is none)
		var cell_index = crates.get_cellv(block_coordinates)
		if cell_index != -1:
			var tiletype = tileset.tile_get_name(cell_index)
			
			# check if that tile can be destroyed (a wooden crate)
			if tiletype == "wooden_crate":
				# remote the crate
				_destroy_crate(block_coordinates)
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
	e.init(p, dirs, Global.bomb_explosion_duration)
