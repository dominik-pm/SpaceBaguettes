extends Node2D

class_name Item

var item

var taken = false
var can_free = false

func init(i):
	item = i
	$Icon.texture = load(Items.icons[item])

func _on_PickupArea_body_entered(body):
	if not taken:
		if body is Player:
			$PickUp.play() # play pick up sound
			body.get_item(item)
			taken = true
			fade_out()

func fade_out():
	$AnimationPlayer.play("fade")

func _on_AnimationPlayer_animation_finished(anim_name):
	# small logic to only queue free, when the animation and the sound is finished
	if can_free:
		queue_free()
	can_free = true

func _on_PickUp_finished():
	if can_free:
		queue_free()
	can_free = true
