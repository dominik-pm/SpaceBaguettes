extends Area2D

#onready var col = $CollisionShape2D

func _ready():
	$Timer.wait_time = Global.bomb_explosion_duration
	$Timer.start()
	$DamageDelay.wait_time = 0.25
	$DamageDelay.start()
	monitoring = false

func _on_DamageDelay_timeout():
	monitoring = true

func _on_Node2D_body_entered(body):
	if body is PlayerHitbox:
		var player_to_damage = body.player
		var player_placed_id = get_parent().pid_fired
		
		# stats
		if player_to_damage.pid != player_placed_id:
			player_to_damage.game.player_hit_enemy(int(player_placed_id))
		
		player_to_damage.get_hit()

func _on_Timer_timeout():
	queue_free()
