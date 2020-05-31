extends Camera2D

var timer

var amplitude
export var shake : = false setget set_shake
export(float, EASE) var DAMP_EASING : = 1.0

export var shake_amplitude : = 0.25
export var shake_duration := 0.25

func _ready():
	timer = $TimerShake
	
	set_process(false)
	self.shake_duration = shake_duration
	amplitude = shake_amplitude

func _process(delta):
	global_transform.origin.y -= delta*10
	
	var damping := ease(timer.time_left / timer.wait_time, DAMP_EASING)
	
	# shake
	offset_v = rand_range(amplitude, -amplitude) * damping
	offset_h = rand_range(amplitude, -amplitude) * damping

func _on_TimerShake_timeout():
	self.shake = false

func request_camera_shake(multiplier):
	amplitude = shake_amplitude * multiplier
	self.shake_duration = shake_duration
	self.shake = true

func set_duration(value: float) -> void:
	if timer != null:
		shake_duration = value
		timer.wait_time = shake_duration

func set_shake(value: bool) -> void:
	shake = value
	set_process(shake)
	#offset = 0 # in 2d
	offset_h = 0
	offset_v = 0
	if shake:
		timer.start()
