extends PanelContainer

onready var player_name = $Control/PlayerName

export (NodePath) var player_icon

export (NodePath) var lab_health
export (NodePath) var lab_bombs
export (NodePath) var lab_baguettes

export (NodePath) var lab_speed
export (NodePath) var lab_bomb_range
export (NodePath) var lab_explosion_strength
export (NodePath) var lab_bomb_move

var bombs_cur = 0
var bombs_cnt = 0

func _ready():
	lab_health = get_node(lab_health)
	lab_bombs = get_node(lab_bombs)
	lab_baguettes = get_node(lab_baguettes)
	
	lab_speed = get_node(lab_speed)
	lab_bomb_range = get_node(lab_bomb_range)
	lab_explosion_strength = get_node(lab_explosion_strength)
	lab_bomb_move = get_node(lab_bomb_move)

func init(pid):
	get_node(player_icon).texture = load(Global.player_icon_paths["player"+str(pid)])
	# error checking
	if Global.player_names[int(pid)-1] == "":
		player_name.text = "Player"+str(pid)
	elif Global.player_names[int(pid)-1] == "@":
		player_name.text = "Bot "+str(pid)
	else:
		player_name.text = Global.player_names[int(pid)-1]

func get_damage():
	$AnimationPlayer.play("get_damage")

func died():
	$AnimationPlayer.play("die")

func update_health(h):
	lab_health.text = str(h)
func update_current_bombs(b):
	bombs_cur = b
	lab_bombs.text = str(bombs_cur)+"/"+str(bombs_cnt)
func update_bombs(b):
	bombs_cnt = b
	#lab_bombs.text = str(b)
	lab_bombs.text = str(bombs_cur)+"/"+str(bombs_cnt)
func update_baguettes(b):
	lab_baguettes.text = str(b)

func update_speed(s):
	lab_speed.text = str(s)
func update_bomb_range(b):
	lab_bomb_range.text = str(b)
func update_explosion_strength(e):
	lab_explosion_strength.text = str(e)
func update_bomb_move(b):
	lab_bomb_move.text = str(b)
