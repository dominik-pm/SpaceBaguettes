extends ParallaxBackground

export var moving = false

export var speed = -12

func _process(delta):
	if moving:
		$Near.motion_offset.x += speed * delta * $Near.motion_scale.x
		$Middle.motion_offset.x += speed * delta * $Middle.motion_scale.x
		$Far.motion_offset.x += speed * delta * $Far.motion_scale.x
