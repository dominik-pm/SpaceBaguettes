extends BotState

# returns true/false if this state wants to be active
func get_target():
	return null

# check if everything is safe
func update(target):
	# maybe also check the whole path (including target and position at once)
	# -> when pathfinding works and bot has a path
	
	# returns null if everything is fine
	# otherwise, returns a new safe location
	if target != null:
		if is_loc_save(target):
			# target is safe, go towards it
			#print("target safe")
			return null
	if is_loc_save(bot.coord) and target != null:
		# target is not safe and position is safe -> stay
		#print("pos safe")
		return bot.coord
	if is_loc_save(bot.coord) and target == null:
		# location is safe and theres no target
		#print("safe no target")
		return null
	else:
		# get a safe location
		var bomb = is_bomb_explosion_in_range(bot.coord)
		var bagu = is_baguette_danger(bot.coord)
		var safe_loc = null
		if bomb != null:
			safe_loc = get_save_loc(bot.coord, bomb)
		elif bagu != null:
			safe_loc = get_save_loc(bot.coord, bagu)
		print("Bot defending: getting safe loc: " + str(safe_loc))
		return safe_loc

# called when the target is reached
func target_reached():
	pass

# called when this state is aborted (defending is more important)
func abort():
	pass

func _to_string():
	return "Defending"

func is_loc_save(pos):
	var bomb = is_bomb_explosion_in_range(pos)
	var bagu = is_baguette_danger(pos)
	return bomb == null and bagu == null

func get_save_loc(pos, danger):
	var target = null
	
	# get the direction away from danger
	var dist = (pos-danger.coord).length()
	var d = pos-danger.coord
	if abs(d.x) > abs(d.y):
		d.y = 0
	else:
		d.x = 0
	d = d.normalized()
	
	if danger is Bomb:
		# idea: 
		# 1. if not on bomb:
			# walk away out of the fireline (normal to dir)
			# if not possible: walk one block further away (dir)
		# 2. else: 
			# walk one block away
		
		var bomb = danger
		
		if d == Vector2.ZERO:
			# on the bomb
			# go in any direction possible
			for i in range(4):
				var k = -1 if i < 2 else 1 # -1, -1, 1, 1
				var x = (i%2)*k
				var y = ((i+1)%2)*k
				if bot.lane_free(pos, Vector2(x, y), 1):
					target = pos+Vector2(x, y)
					break
		else:
			# check if we can walk away sideways
			if bot.lane_free(pos, Vector2(d.y, d.x), 1):
				target = pos+Vector2(d.y, d.x)
			elif bot.lane_free(pos, -Vector2(d.y, d.x), 1):
				target = pos-Vector2(d.y, d.x)
			# else: walk away (away from bomb)
			elif bot.lane_free(bomb.coord, d*dist, 1):
				target = bomb.coord+d*(dist+1)
			else:
				# schade eigentlich
				return null
		
	elif danger is Baguette:
		# idea: 
		# 1. walk away out of the baguettes trajectory (normal to dir)
			# if not possible: walk one block further away (dir)
		# 2. else: 
			# walk one block away
		
		var baguette = danger
		# check if we can walk away sideways
		if bot.lane_free(pos, Vector2(d.y, d.x), 1):
			target = pos+Vector2(d.y, d.x)
		elif bot.lane_free(pos, -Vector2(d.y, d.x), 1):
			target = pos-Vector2(d.y, d.x)
		else:
			target = pos+d
	
	return target



"""
Bullshit:
	
		var pos = bot.coord
	var new_target = null
	
	# check if position is save
	var bomb = is_bomb_explosion_in_range(pos)
	var bagu = is_baguette_danger(pos)
	
	# if its not save, get a target pos
	if bomb != null:
		# a bomb could harm us -> get a new target
		new_target = get_save_loc(pos, bomb)
	elif bagu != null:
		# a baguette could harm us
		new_target = get_save_loc(pos, bagu)
	
	# if there's a target, and there's no new target already set
	if target != null and new_target == null:
		# check if we need a new target
		
		bomb = is_bomb_explosion_in_range(target)
		bagu = is_baguette_danger(target)
		
		if bomb != null:
			# a bomb can harm us at the target
			new_target = get_save_loc(pos, bomb)
		elif bagu != null:
			# a baguette can harm us at the target
			new_target = get_save_loc(pos, bagu)
	
	if new_target != null:
		return new_target
	else:
		return target # everything is save, do as you were
"""
