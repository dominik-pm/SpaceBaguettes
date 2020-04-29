extends Node2D

var tile = preload("res://Scenes/Effects/Bomb/ExplosionTile.tscn")
var tilesize = 64

func init(pos, dirs):
	$AnimatedSprite.play("explode")
	global_transform.origin = pos
	
	for i in range(4):
		for j in range(dirs[i]):
			var k = 1
			if i > 1:
				k = -1
			var p = tilesize*Vector2(k*(j+1)*(i%2), -k*(j+1)*((i+1)%2))
			var t = tile.instance()
			add_child(t)
			t.transform.origin = p

func _on_AnimatedSprite_animation_finished():
	queue_free()
