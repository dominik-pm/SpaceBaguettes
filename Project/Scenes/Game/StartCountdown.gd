extends CanvasLayer

signal countdown_finished

onready var lab = $CenterControl/Scaler/Label
onready var anim = $AnimationPlayer

var timer = null
var cnt = 3

func _ready():
	timer = Timer.new()
	get_tree().root.add_child(timer)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.wait_time = 1
	timer.one_shot = true

func start_countdown():
	update_label()
	timer.start()

func update_label():
	if cnt == 0:
		lab.text = "start!"
	else:
		lab.text = str(cnt)
		
		# play sound
		$Tick.stream.loop = false
		$Tick.play()
	
	# play animation
	anim.play("countdown")

func _on_timer_timeout():
	cnt -= 1
	if cnt > 0:
		timer.start()
	else:
		emit_signal("countdown_finished")
	update_label()
