extends Node2D

var particles = []

var d
var ttl

func _ready():
	for c in get_children():
		if c is Particles2D:
			particles.push_back(c)
			c.emitting = false
			c.one_shot = true

func init(pos, dirs, time):
	global_transform.origin = pos
	# dirs is the length of the explosion in each direction (top, right, bot, left)
	d = dirs
	ttl = time
	
	create_hit_tiles()
	
	#start_particles()

func create_hit_tiles():
	for i in range(4):
		for j in range(d[i]):
			var k = 1
			if i > 1:
				k = -1
			var p = Global.tilesize*Vector2(k*(j+1)*(i%2), -k*(j+1)*((i+1)%2))
			var t = Preloader.explosion_hitbox.instance()
			add_child(t)
			t.init(ttl)
			t.transform.origin = p

func start_particles():
	# not correct
	for i in range(particles.size()):
		if d[i] != 0:
			particles[i].lifetime = ttl
			#$top.visibility_rect.grow(d[i])
			#particles[i].visibility_rect = particles[i].visibility_rect.grow(d[i])
			particles[i].emitting = true
