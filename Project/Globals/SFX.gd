extends Node

const min_db = -30
const max_db = 10

enum {
	PLAYER_DAMAGE,
	PLAYER_DIE
}

enum audiobus {
	MASTER,
	SOUND,
	MUSIC
}

func set_volume(bus, vol : float):
	var bus_idx
	
	match bus:
		audiobus.MASTER:
			bus_idx = AudioServer.get_bus_index("Master")
		audiobus.SOUND:
			bus_idx = AudioServer.get_bus_index("Sound")
		audiobus.MUSIC:
			bus_idx = AudioServer.get_bus_index("Music")
		_:
			pass
	
	if vol == 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		
		var db_value = ( (vol/100.0) * (abs(max_db)+abs(min_db)) ) + min_db
		
		AudioServer.set_bus_volume_db(bus_idx, db_value)
