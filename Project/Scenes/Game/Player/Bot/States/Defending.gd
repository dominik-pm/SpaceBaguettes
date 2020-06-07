extends BotState

# returns true/false if this state wants to be active
func has_target():
	# returns true if we are not on a save location
	if not is_loc_save(bot.coord):
		# bots position is unsave
		return true
	elif bot.target != null and not is_loc_save(bot.target):
		# bots target is unsave
		return true
	else:
		# bot is save
		return false

# to figure out where to go
func update(target):
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

# called when the target is reached
func exit():
	print("Bot: exiting from defending")

func _to_string():
	return "Defending"

func is_loc_save(pos):
	var bomb = is_bomb_explosion_in_range(pos)
	var bagu = is_baguette_danger(pos)
	return bomb == null and bagu == null

func get_save_loc(pos, danger):
	var target = null
	
	# get the direction away from danger
	var d = pos-danger.coord
	if abs(d.x) > abs(d.y):
		d.y = 0
	else:
		d.x = 0
	d = d.normalized()
	
	if danger is Bomb:
		var bomb = danger
		
		if d == Vector2.ZERO:
			# on the bomb
			# -> set x or y of direction to 1/-1 so that code below works
			randomize()
			var r = int(floor(rand_range(0, 5)))
			d.x = (r%2)*(r-2) 		# 0:  0; 1: -1; 2: 0; 3: 1
			d.y = ((r+1)%2)*(r-1) 	# 0: -1; 1:  0; 2: 1; 3: 0
		
		# check if we can walk away normal to the danger
		if bot.lane_free(bomb.coord, d, bomb.explosion_size + 1):
			target = bomb.coord+(d * (bomb.explosion_size+1) )
		# else check if we can walk away sideways
		elif bot.lane_free(pos, Vector2(d.y, d.x), 1):
			target = pos+Vector2(d.y, d.x)
		elif bot.lane_free(pos, -Vector2(d.y, d.x), 1):
			target = pos-Vector2(d.y, d.x)
		else:
			# small knight move (one forward, one up/down)
			if bot.lane_free(pos+d, Vector2(d.y, d.x), 1):
				target = pos+d+Vector2(d.y, d.x)
			elif bot.lane_free(pos+d, -Vector2(d.y, d.x), 1):
				target = pos+d-Vector2(d.y, d.x)
		
		
	elif danger is Baguette:
		var baguette = danger
		# check if we can walk away sideways
		if bot.lane_free(pos, Vector2(d.y, d.x), 1):
			target = pos+Vector2(d.y, d.x)
		elif bot.lane_free(pos, -Vector2(d.y, d.x), 1):
			target = pos-Vector2(d.y, d.x)
		else:
			# small knight move (one forward, one up/down)
			if bot.lane_free(pos+d, Vector2(d.y, d.x), 1):
				target = pos+d+Vector2(d.y, d.x)
			elif bot.lane_free(pos+d, -Vector2(d.y, d.x), 1):
				target = pos+d-Vector2(d.y, d.x)
	
	return target
