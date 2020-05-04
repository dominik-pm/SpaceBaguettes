extends Node2D

class_name Item

var item

var taken = false

func init(i):
	item = i
	$Icon.texture = load(Items.icons[item])

func _on_PickupArea_body_entered(body):
	if not taken:
		if body is PlayerHitbox:
			$PickUp.play() #play pick up sound
			body.player.get_item(item)
			taken = true
			fade_out()

func fade_out():
	$AnimationPlayer.play("fade")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
