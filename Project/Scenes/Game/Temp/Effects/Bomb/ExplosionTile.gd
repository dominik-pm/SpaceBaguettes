extends Area2D

func _ready():
	$AnimationPlayer.play("Fade")

func _on_ExplosionTile_body_entered(body):
	if body is Player:
		body.get_hit()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
