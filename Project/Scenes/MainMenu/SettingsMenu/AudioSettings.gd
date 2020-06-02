extends VBoxContainer

onready var master_slider = $Master/MasterSlider
onready var sound_slider = $Sound/SoundSlider
onready var music_slider = $Music/MusicSlider

onready var master_player = $Master/MasterSample
onready var sound_player = $Sound/SoundSample
onready var music_player = $Music/MusicSample

var can_play = false

func _ready():
	var vol = Settings.get_setting("audio", "master_volume")
	master_slider.value = vol
	_on_MasterSlider_value_changed(vol)
	vol = Settings.get_setting("audio", "sound_volume")
	sound_slider.value = vol
	_on_SoundSlider_value_changed(vol)
	vol = Settings.get_setting("audio", "music_volume")
	music_slider.value = vol
	_on_MusicSlider_value_changed(vol)
	
	can_play = true

func _on_MasterSlider_value_changed(value):
	Settings.set_setting("audio", "master_volume", value)
	SFX.set_volume(SFX.audiobus.MASTER, value)
	# play sample sound
	if not master_player.playing and can_play:
		sound_player.playing = false
		music_player.playing = false
		master_player.play()

func _on_SoundSlider_value_changed(value):
	Settings.set_setting("audio", "sound_volume", value)
	SFX.set_volume(SFX.audiobus.SOUND, value)
	# play sample sound
	if not sound_player.playing and can_play:
		master_player.playing = false
		music_player.playing = false
		sound_player.play()

func _on_MusicSlider_value_changed(value):
	Settings.set_setting("audio", "music_volume", value)
	SFX.set_volume(SFX.audiobus.MUSIC, value)
