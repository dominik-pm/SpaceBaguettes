extends Area2D

func _ready():
	$Timer.wait_time = Global.bomb_explosion_duration
	$Timer.start()

func _on_Node2D_body_entered(body):
	if body is PlayerHitbox:
		body.player.get_hit()

func _on_Timer_timeout():
	queue_free()
