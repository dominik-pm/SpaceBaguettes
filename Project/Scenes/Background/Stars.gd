extends ParallaxBackground

export var moving = false

#onready var anim = $AnimationPlayer

var speed = -10

func _ready():
	pass
#	if moving:
#		anim.play("move")

func _process(delta):
	if moving:
		$Near.motion_offset.x += speed * delta * $Near.motion_scale.x
		$Middle.motion_offset.x += speed * delta * $Middle.motion_scale.x
		$Far.motion_offset.x += speed * delta * $Far.motion_scale.x
