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
	HEALTH: ICON_PATH + "Health.png",
	MOREBOMBS: ICON_PATH + "MoreBombs.png",
	BAGUETTES: ICON_PATH + "Baguette.png",
	SPEED: ICON_PATH + "FastBoots.png",
	BOMBRANGE: ICON_PATH + "BombRange.png",
	EXPLOSIONSTRENGTH: ICON_PATH + "StrongerExplosions.png",
	BOMBMOVING: ICON_PATH + "BombMove.png"
}
