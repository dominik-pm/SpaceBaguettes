extends Node2D

var d

var pid_fired = null

func init(pos, dirs, pid):
	global_transform.origin = pos
	# dirs is the length of the explosion in each direction (top, right, bot, left)
	d = dirs
	pid_fired = pid
	
	create_hit_tiles()
	
	# maybe not need (but it would never be removed)
	var t = Timer.new()
	t.wait_time = Global.bomb_explosion_duration*1.5
	add_child(t)
	t.start()
	t.connect("timeout", self, "_on_destroy_timout")
func _on_destroy_timout():
	queue_free()

func create_hit_tiles():
	var k # to calculate dir
	var dir
	
	# create one for the center (where the bomb was)
	spawn_explosion_hit_tile(Vector2(0, 0))
	
	# for every direction
	for i in range(4):
		k = 1
		if i > 1:
			k = -1
		dir = Vector2(k*(i%2), -k*((i+1)%2))
		
		if d[i] > 0:
			var f = Preloader.fireline.instance()
			add_child(f)
			f.global_transform.origin = global_transform.origin
			f.init(dir, d[i])
		
		# for every explosion tile in that lane
		for j in range(d[i]):
			var p = Global.tilesize*Vector2(dir.x*(j+1), dir.y*(j+1))
			spawn_explosion_hit_tile(p)

func spawn_explosion_hit_tile(pos):
	var t = Preloader.explosion_hitbox.instance()
	add_child(t)
	t.transform.origin = pos
