extends Node2D

export var stopping = false
export var auto_fly_away = false

func fly_in():
	$AnimationPlayer.play("fly_in")

func fly_away():
	$AnimationPlayer.play("fly_away")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fly_in":
		if not stopping:
			$AnimationPlayer.play("flying")
			if auto_fly_away:
				$AnimationPlayer.get_animation("flying").loop = false
		else:
			$AnimationPlayer.play("stop")
	elif anim_name == "flying":
		if auto_fly_away:
			$AnimationPlayer.play("fly_away")
