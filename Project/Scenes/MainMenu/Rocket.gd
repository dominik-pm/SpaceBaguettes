extends Node2D

func _ready():
	$Flame.play("flying")
	$AnimationPlayer.play("flying")
