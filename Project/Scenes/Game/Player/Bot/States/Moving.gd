extends BotState

var movement_range = Vector2(2, 2)

# returns true/false if this state wants to be active
func has_target():
	return false#true

# to figure out where to go
func update(target):
	var pos = bot.coord
	var dir = Vector2.ZERO
	
	# one of the dir coordinate should be 2 (so that the target is in a radius)
	randomize()
	if int(rand_range(0, 2)) % 2 == 0:
		dir.x = 2
		dir.y = int(rand_range(0, movement_range.x+1))
	else:
		dir.y = 2
		dir.x = int(rand_range(0, movement_range.x+1))
	
	# check if there is no block
	var cnt = 0
	while game.check_block(pos+dir) != 0 or cnt >= 5:
		cnt += 1
		# get closer on x or y
		if int(rand_range(0, 2)) % 2 == 0:
			if dir.x-1 >= -movement_range.x:
				dir.x += -1
			elif dir.y-1 >= -movement_range.y:
				dir.y += -1
	
	if cnt == 0:
		# coulndt find block to move to -> return old target
		return target
	else:
		return pos+dir

# called when the target is reached
func exit():
	pass

func _to_string():
	return "Moving"
