extends BotState

var item_radius = 3

# returns true/false if this state wants to be active
func get_target():
	var new_target = get_nearest_item(bot.coord)
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
	return "Looting"


func get_nearest_item(from_pos):
	var nearest = null

	for item in bot.all_items:
		if not item.taken:
			if nearest != null:
				var dist = (item.coord-from_pos).length()
				if dist < (nearest-from_pos).length():
					nearest = item.coord
			else:
				nearest = item.coord

	if nearest != null:
		if abs(nearest.x-from_pos.x) <= item_radius and abs(nearest.y-from_pos.y) <= item_radius:
			return nearest
	
	return null
