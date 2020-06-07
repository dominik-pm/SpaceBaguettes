extends BotState

# returns true/false if this state wants to be active
func has_target():
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
	return "Idle"
