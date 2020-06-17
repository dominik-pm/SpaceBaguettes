extends BotState

var dist = null

# returns true/false if this state wants to be active
func get_target():
	dist = null
	
	# check if he can even shoot or place bomb
	if (bot.can_shoot and bot.baguette_count > 0) or bot.can_place_bomb:
		
		for other in bot.other_players:
			# only if the other is hittable
			if not other.invincible:
			
				var p = game.get_coord(other.global_transform.origin)
				if p.x == bot.coord.x or p.y == bot.coord.y:
					var dir = p-bot.coord
					dist = dir.length()
					dir = dir.normalized()
					if bot.lane_free(bot.coord, dir, dist):
						# player is in sight
						if bot.facing == dir:
							# bot already facing at the other player
							return bot.coord
						elif dist > 1:
							# bot facing the wrong direction
							return bot.coord + dir
	return null

# to figure out where to go
func update(target):
	return target

# called when the target is reached
func target_reached():
	if not bot.try_shoot():
		if dist != null:
			if dist <= bot.explosion_range:
				bot.try_place_bomb()

# called when this state is aborted (defending is more important)
func abort():
	pass

func _to_string():
	return "Attacking"

"""
# offensive manouver
if target_pos == Vector2.ZERO:
	# move to a crate
	# 1. get crates in a radius of 3
	var nearby_crates = []
	for x in range(-3, 4):
		for y in range(-3, 4):
			var p = coord+Vector2(x, y)
			if game.check_block(p) == 1:
				# block is a crate
				nearby_crates.push_back(p)
	if nearby_crates.size() > 0:
		# 2. get the nearest one
		var nearest = null
		var crate = null
		for c in nearby_crates:
			var dist = (c-coord).length()
			if nearest == null or dist <= nearest:
				if dist == nearest:
					pass # Make it 50/50 to switch over
				nearest = dist
				crate = c
		if crate != null:
			target_pos = crate+(coord-crate).normalized()
		else:
			print("Bot: bot.gd:<223 error")
	else:
		print("Bot: no nearby crates :(")
	
	if (target_pos != Vector2.ZERO):
		print("Bot: target set: " + str(target_pos))


	# check if target is save
	var bo = is_bomb_explosion_in_range(target_pos)
	var ba = is_baguette_danger(target_pos)
	if bo != null or ba != null:
		target_pos = Vector2.ZERO
		print("Bot: target dangerous, aborted")
"""
