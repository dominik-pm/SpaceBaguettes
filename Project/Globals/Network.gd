extends Node

const PORT = 31400
var ip = ""
var peer = null
var local_id = null
var nickname = ""

var connected_players = {}

signal update_connections
signal server_closed
signal failed_to_join
signal start_game

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('connection_failed', self, '_connection_failed')
	
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		close_connection()
		get_tree().quit()

# MENU CALLED
func host_game(nn):
	nickname = nn
	
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(PORT, 4)
	if err == OK:
		get_tree().set_network_peer(peer)
		
		local_id = get_tree().get_network_unique_id()
		
		print("opened server!")
		ip = "unknown" # maybe get it somehow (idk)
		
		connected_players[local_id] = str(nn)
		update_connections(connected_players)
	else:
		print("failed to create server: " + str(err))

func join_game(nn, address):
	nickname = nn
	ip = address
	
	print("trying to connect to: " + ip + ":" + str(PORT))
	
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip, PORT)
	if err == OK:
		get_tree().set_network_peer(peer)
		local_id = get_tree().get_network_unique_id()
	else:
		emit_signal("failed_to_join")
		print("failed to join to server: " + str(err))

func close_connection():
	if peer != null:
		rpc("server_closed")
		peer.close_connection()
		print("closed connection")

func start_game():
	if connected_players.size() > 1:
		print("starting game!")
		peer.refuse_new_connections = true
		rpc("start", connected_players)
	else:
		rpc("start", connected_players)
		print("not enough players")

func restart_game():
	if local_id == 1:
		rpc("restart")


func get_ip():
	return str(ip) + ":" + str(PORT)


# NETWORK SIGNALS
func _connected_to_server():
	print("Connected!")
	rpc_id(1, "client_connected", local_id, nickname)
func _connection_failed():
	print("Connection failed!")
func _on_player_connected(id):
	if id == 1:
		# server closed
		print("server closed")
		emit_signal("server_closed")
func _on_player_disconnected(id):
	if local_id == 1:
		connected_players.erase(id)
		if connected_players.size() < 4:
			peer.refuse_new_connections = false
		rpc("update_connections", connected_players)
	else:
		pass


# TO SERVER CALLED
remote func client_connected(id, nn):
	# we are the server
	connected_players[id] = str(nn)
	if connected_players.size() >= 4:
		peer.refuse_new_connections = true
	rpc("update_connections", connected_players)

# TO CLIENTS
remote func server_closed():
	print("server closed")
	peer.close_connection()
	emit_signal("server_closed")

# TO EVERYONE (INCLUDING HOST)
sync func restart():
	emit_signal("start_game")
sync func start(players):
	connected_players = players
	
	# init playing
	var i = 0
	for id in players:
		Global.players[i] = str(id)
		Global.player_names[i] = players[id]
		i += 1
	# init not playing
	for j in range(4-i):
		Global.players[j+i] = "-"
		Global.player_names[j+i] = "-"
	# change scene
	emit_signal("start_game")
sync func update_connections(players):
	connected_players = players
	emit_signal("update_connections", connected_players)
