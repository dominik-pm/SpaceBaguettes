extends HBoxContainer

export (Array, NodePath) var player_info_containers
var player_infos = []

func _ready():
	for c in player_info_containers:
		player_infos.push_back(get_node(c))

func update_info(player : int, item, value):
	var p = player_infos[player-1]
	match item:
		Items.HEALTH:
			p.update_health(value)
		Items.MOREBOMBS:
			p.update_bombs(value)
		Items.BAGUETTES:
			p.update_bombs(value)
		_:
			pass
