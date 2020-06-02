extends Node

const ICON_PATH = "res://Assets/Game/Items/"

enum {
	TESTBUFF,
	HEALTH,
	MOREBOMBS,
	BAGUETTES,
	SPEED,
	BOMBRANGE,
	EXPLOSIONSTRENGTH,
	BOMBMOVING
}

var icons = {
	TESTBUFF: ICON_PATH + "error.png",
	HEALTH: ICON_PATH + "ExtraLive.png",
	MOREBOMBS: ICON_PATH + "MoreBombs.png",
	BAGUETTES: ICON_PATH + "Baguettes.png",
	SPEED: ICON_PATH + "FastBoots.png",
	BOMBRANGE: ICON_PATH + "BombRange.png",
	EXPLOSIONSTRENGTH: ICON_PATH + "StrongerExplosions.png",
	BOMBMOVING: ICON_PATH + "BombMove.png"
}

# items get chosen from a pool where each item is in it [n] times
var drop_probabilities = {
	TESTBUFF: 0,
	HEALTH: 1,
	MOREBOMBS: 3,
	BAGUETTES: 3,
	SPEED: 1,
	BOMBRANGE: 2,
	EXPLOSIONSTRENGTH: 1,
	BOMBMOVING: 2
}
