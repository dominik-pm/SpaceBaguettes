extends BotState

# returns true/false if this state wants to be active
func has_target():
	return false

# to figure out where to go
func update(target):
	return target

# called when the target is reached
func exit():
	pass

func _to_string():
	return "Looting"
