extends BotState

var crate_radius = 3

#var position_to_place = null

# returns true/false if this state wants to be active
func get_target():
	#return null # disabled
	
	var nearby_crates = crates_nearby(bot.coord)
	if nearby_crates.size() > 0:
		var new_target = get_best_crate_pos(nearby_crates)
		if new_target != null:
			# found a position to place
			#position_to_place = new_target
			#if bot.coord != new_target:
			return new_target
	
	return null

# to figure out where to go
func update(target):
	#if target == null:
	#	print("updating")
	#	#if position_to_place == null:
	#		#print("updating2")
	#	var nearby_crates = crates_nearby(bot.coord)
	#	if nearby_crates.size() > 0:
	#		print("updating3")
	#		var new_target = get_best_crate_pos(nearby_crates)
	#		if new_target != null:
	#			# found a position to place
	#			print("updating4")
	#			#position_to_place = new_target
	#			return new_target
	#	#else:
	#	#	pass
	#		# return position_to_place
	
	return target

# called when the target is reached
func target_reached():
	# lay bomb
	#if position_to_place != null:
	#if bot.coord == position_to_place:
	#print("Bot Farming: placing bomb")
	bot.try_place_bomb()
	#position_to_place = null

# called when this state is aborted (defending is more important)
func abort():
	pass


func _to_string():
	return "Farming"


func crates_nearby(pos):
	# move to a crate
	var nearby_crates = []
	for x in range(-crate_radius, crate_radius+1):
		for y in range(-crate_radius, crate_radius+1):
			var p = pos+Vector2(x, y)
			if game.check_block(p) == 1:
				# block is a crate
				nearby_crates.push_back(p)
	return nearby_crates

func get_best_crate_pos(crates):
	# 1. criteria: get the nearest ones (all with the same distance)
	var best_crates = get_nearest_crates(crates)
	
	#print(best_crates.size())
	
	# 2. criteria: get the ones with the most crates to destroy
	var new_bests = []
	if best_crates.size() > 0:
		new_bests = get_with_most_crates(best_crates)
		
		# get a random one out of all bests
		randomize()
		var best_one = new_bests[floor(rand_range(0, new_bests.size()))]
		#print("best one is: " + str(best_one))
		
		return best_one
	
	else:
		#print("Bot farming: didnt find best loc for crate, even tough there are crates availiable")
		return null

func get_nearest_crates(crates):
	var best_crates = []
	var nearest = null
	var crate = null
	
	for c in crates:
		# get the pos where the bomb can be placed
		var pos = c
		var d = bot.coord-pos
		if abs(d.x) > abs(d.y):
			d.y = 0
		else:
			d.x = 0
		
		pos = pos+(d).normalized()
		
		# check if this block is free
		if game.check_block(pos) == 0:
			var dist = (pos-bot.coord).length()
			if nearest == null or dist <= nearest:
				if dist == nearest:
					best_crates.push_back(pos)
				else:
					best_crates = [pos]
				nearest = dist
				crate = pos
	
	return best_crates

func get_with_most_crates(crates):
	var max_cnt = 0
	var bests = []
	
	for pos in crates:
		var cnt = 0
		for i in range(4):
			# check each direction for a crate
			var d = 1 if i < 2 else -1
			var p = Vector2(pos.x+(i%2)*1*d, pos.y+((i+1)%2)*1*d)
			if game.check_block(p) == 1:
				cnt += 1
		#print("found " + str(cnt) + " crate for position: " + str(pos))
		if cnt >= max_cnt:
			if cnt == max_cnt:
				bests.push_back(pos)
			else:
				bests = [pos]
			max_cnt = cnt
	return bests
