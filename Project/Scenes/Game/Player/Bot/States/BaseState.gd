extends Node

class_name BotState

var bot = null
var game = null

func init(b, g):
	bot = b
	game = g

# -- OVERRITE THESE IN THE STATE -->

# returns true/false if this state wants to be active
func get_target():
	return null

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
	return "BaseState"

# <-- OVERRITE THESE IN THE STATE --

# -- METHODS THAT STATES CAN USE -->
func is_bomb_explosion_in_range(pos):
	for bomb in bot.all_bombs:
		if bomb.coord.x == pos.x or bomb.coord.y == pos.y:
			# a bomb is in line
			# check if its explosion strength could be dangerous
			if bomb.explosion_size != null:
				if bomb.explosion_size >= (bomb.coord-pos).length():
					# check if there are blocks between
					if bot.lane_free(bomb.coord, (bomb.coord-pos).normalized(), bomb.explosion_size-1):
						return bomb
	return null

func is_baguette_danger(pos):
	for baguette in bot.all_baguettes:
		if baguette.coord.x == pos.x:
			# baguette has same x
			var dist = (pos.y-baguette.coord.y)
			if baguette.dir.y * dist > 0: # a*b -> a and b are both negative/positive
				# baguette is flying towards us
				if bot.lane_free(baguette.coord, Vector2(0, baguette.dir.y), dist):
					# no blocks between baguette an pos
					return baguette
		elif baguette.coord.y == pos.y:
			# baguette has same y
			var dist = (pos.x-baguette.coord.x)
			if baguette.dir.x * dist > 0: # a*b -> a and b are both negative/positive
				# baguette is flying towards us
				if bot.lane_free(baguette.coord, Vector2(baguette.dir.x, 0), dist):
					# no blocks between baguette an pos
					return baguette
	return null
