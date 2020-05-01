extends Area2D

func init(t):
	yield(get_tree().create_timer(t), "timeout")
	queue_free()

func _on_Node2D_body_entered(body):
	if body is Player:
		body.get_hit()
