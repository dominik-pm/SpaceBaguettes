extends HBoxContainer

export (NodePath) var player_container1
var player_infos = []

func _ready():
	pass

func update_info(pid : int, item, value):
	player_infos.push_back(get_node(player_container1))
	
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

func remove_player(pid : int):
	player_infos[pid].died()
