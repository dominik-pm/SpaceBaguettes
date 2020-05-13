extends Control

export (NodePath) var player_container1
export (NodePath) var player_container2
export (NodePath) var player_container3
export (NodePath) var player_container4
var player_infos = []

func _ready():
	pass

func init_player_gui():
	player_infos.push_back(get_node(player_container1))
	player_infos.push_back(get_node(player_container2))
	player_infos.push_back(get_node(player_container3))
	player_infos.push_back(get_node(player_container4))
	
	for i in range(Global.player_count):
		player_infos[i].init(i+1)
	for i in range(Global.player_count, 4):
		player_infos[i].hide()

func player_hit(pid : int):
	var p = player_infos[pid-1]
	p.get_damage()

func player_died(pid : int):
	player_infos[pid-1].died()

func update_info(pid : int, item, value):
	if player_infos == []:
		init_player_gui()
	
	var p = player_infos[pid-1]
	match item:
		Items.HEALTH:
			p.update_health(value)
		Items.MOREBOMBS:
			p.update_bombs(value)
		Items.BAGUETTES:
			p.update_baguettes(value)
		Items.SPEED:
			p.update_speed(value)
		Items.BOMBRANGE:
			p.update_bomb_range(value)
		Items.EXPLOSIONSTRENGTH:
			p.update_explosion_strength(value)
		Items.BOMBMOVING:
			p.update_bomb_move(value)
		_:
			pass
