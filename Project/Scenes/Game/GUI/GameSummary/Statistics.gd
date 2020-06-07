extends Control

onready var container = $VBoxContainer

func show_player_stats(stats):
	for player_name in stats:
		#if player_name != "-": # he would not be playing
		var new_player_sum = Preloader.player_summary.instance()
		container.add_child(new_player_sum)
		container.move_child(new_player_sum, container.get_child_count()-2) # add it to the second to last poition
		new_player_sum.init(player_name, stats[player_name])
