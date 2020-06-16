extends BotState

var movement_range = Vector2(2, 2)

# returns true/false if this state wants to be active
func get_target():
	#return null # disabled
	
	var new_target = get_random_loc(bot.coord)
	return new_target

# to figure out where to go
func update(target):
	return target

# called when the target is reached
func target_reached():
	pass

# called when this state is aborted (defending is more important)
func abort():
	pass

func _to_string():
	return "Moving"

func get_random_loc(pos):
	# get all positions
	var positions = []
	for i in range(-movement_range.x, movement_range.x+1):
		for j in range(-movement_range.y, movement_range.y+1):
			var coord = Vector2(i, j)
			if coord.length() != 0:
				if game.check_block(pos+coord) == 0:
						positions.push_back(coord)
	if positions.size() == 0:
		print("Moving: couldnt find block")
		return null
	
	# get the nearest safe location
	var nearest = null
	for loc in positions:
		if nearest == null or loc.length() < nearest.length():
			nearest = loc
	
	return nearest + pos

"""
old alg to find random loc
func test(pos):
	var dir = Vector2.ZERO
	
	# one of the dir coordinate should be 2 (so that the target is in a radius)
	randomize()
	if int(rand_range(0, 2)) % 2 == 0:
		dir.x = 2
		dir.y = int(rand_range(0, movement_range.x+1))
	else:
		dir.y = 2
		dir.x = int(rand_range(0, movement_range.x+1))
	
	print(dir)
	
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
	
	print(cnt)
	
	if cnt == 0:
		# coulndt find block to move to
		print("Moving: couldnt find block")
		return null
	else:
		return pos+dir
"""
