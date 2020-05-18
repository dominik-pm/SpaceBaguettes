extends Node2D

func _ready():
	$Flame.play("flying")
	$AnimationPlayer.play("flying")

func fly_away():
	$AnimationPlayer.play("fly_away")
