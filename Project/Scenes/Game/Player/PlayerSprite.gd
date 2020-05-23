extends Node2D

var anim_player = null

func init(index):
	var idx = index - 1
	for i in range(get_child_count()):
		get_child(i).hide()
	
	anim_player = get_child(idx)
	anim_player.show()
	anim_player.play("idleDown")

func play(anim_name):
	if anim_player != null:
		anim_player.play(anim_name)
	else:
		print("anim player is null")
