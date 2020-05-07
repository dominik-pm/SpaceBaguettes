extends AnimatedSprite

func init(index):
	for i in range(get_child_count()):
		if i != index:
			get_child(index).queue_free()
