extends HBoxContainer

onready var stat_container = $Statistics
onready var lab = $PlayerName 

func init(player_name, stats):
	lab.text = str(player_name)
	
	for key in stats:
		var new_stat = Preloader.player_stat.instance()
		stat_container.add_child(new_stat)
		new_stat.init_stat(key, stats[key])
