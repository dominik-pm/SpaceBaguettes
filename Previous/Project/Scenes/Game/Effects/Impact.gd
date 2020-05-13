extends Node2D

func init(dir : Vector2):
	match dir:
		Vector2(1, 0):
			rotation_degrees = 0
		Vector2(0, 1):
			rotation_degrees = 90
		Vector2(-1, 0):
			rotation_degrees = 180
		Vector2(0, -1):
			rotation_degrees = 270

func _ready():
	$AnimatedSprite.play("impact")

func _on_AnimatedSprite_animation_finished():
	queue_free()
