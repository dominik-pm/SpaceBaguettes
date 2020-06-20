extends Node

const PORT = 31400#25565
var upnp = null
var is_port_open = false
var connecting_ip = ""
var public_ip = null
var peer = null
var local_id = null
var nickname = ""

var connected_players = {}

# for the server
var ready_players = []
var ready_timeout = null

signal update_connections
signal server_closed
signal failed_to_join
signal start_game
signal restart_game
signal start_countdown

func _ready():
	#close_port()
	#return
	
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	get_tree().connect('connection_failed', self, '_connection_failed')
	
	get_tree().set_auto_accept_quit(false)
	
	ready_timeout = Timer.new()
	add_child(ready_timeout)
	ready_timeout.autostart = true
	ready_timeout.one_shot = true
	ready_timeout.wait_time = 10.0
	ready_timeout.connect("timeout", self, "_on_ready_timout")
	
	_request_public_ip()

func _request_public_ip():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_on_request_completed")
	http.request("https://api.ipify.org/?format=json")

func close_port():
	var u = UPNP.new()
	u.discover()
	var gateway = u.get_gateway()
	gateway.delete_port_mapping(PORT, "TCP")
	gateway.delete_port_mapping(PORT, "UDP")

func open_port():
	if upnp == null:
		upnp = UPNP.new()
		var result = upnp.discover()
		
		if result != 0:
			print("couldnt find network devices, err code: " + str(result))
			return false
		
		var gateway = upnp.get_gateway()
		
		if gateway == null:
			if upnp.get_device_count() > 0:
				gateway = upnp.get_device(0)
				if gateway == null or not gateway.is_valid_gateway():
					print("no gateway found")
					return false
			else:
				print("couldnt find any network device")
				return false
		
		gateway.add_port_mapping(PORT, PORT, "SpaceBaguettes", "TCP")
		gateway.add_port_mapping(PORT, PORT, "SpaceBaguettes", "UDP")
		return true
	else:
		return is_port_open

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	public_ip = json.result["ip"]

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		close_connection()
		get_tree().quit()

# MENU CALLED
func host_game(nn):
	is_port_open = open_port()
	
	nickname = nn
	
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(PORT, 4)
	if err == OK:
		get_tree().set_network_peer(peer)
		
		local_id = get_tree().get_network_unique_id()
		
		print("opened server!")
		
		connected_players[local_id] = str(nn)
		update_connections(connected_players)
	else:
		print("failed to create server: " + str(err))

func join_game(nn, address):
	nickname = nn
	connecting_ip = address
	
	print("trying to connect to: " + connecting_ip + ":" + str(PORT))
	
	peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(connecting_ip, PORT)
	if err == OK:
		get_tree().set_network_peer(peer)
		local_id = get_tree().get_network_unique_id()
	else:
		print("failed to create client")
		emit_signal("failed_to_join")

func close_connection():
	connected_players = {}
	if peer != null:
		if local_id == 1:
			rpc("server_closed")
		yield(get_tree().create_timer(0.5), "timeout")
		peer.close_connection()
		print("closed connection")

func start_game():
	if local_id == 1:
		if connected_players.size() > 1:
			print("loading game!")
			ready_timeout.start()
			peer.refuse_new_connections = true
			rpc("start", connected_players)
		else:
			print("not enough players")

func restart_game():
	if local_id == 1:
		rpc("restart")


func get_ip():
	if local_id == 1:
		var s = ""
		if public_ip != null:
			s = str(public_ip)
		elif upnp != null:
			s = upnp.query_external_address()
		
		if not is_port_open:
			return [get_local_ip(), false]
		elif s != "":
			return [s, true]
		else:
			return ["unknown", true]
	# he's a client, return the ip that he connected to
	else:
		return [connecting_ip, true]

func get_local_ip():
	var s = IP.get_local_addresses()
	var second_choice = ""
	for c in s:
		if c.length() <= 15 and c.length() > 7:
			if c.substr(0, 3) == "192" or c.substr(0, 2) == "10": 
				return c
			else:
				second_choice = c
	return second_choice


# NETWORK SIGNALS
func _connected_to_server():
	print("Connected!")
	rpc_id(1, "client_connected", local_id, nickname)
func _connection_failed():
	print("Connection failed!")
	emit_signal("failed_to_join")
func _on_player_connected(id):
	pass
func _on_player_disconnected(id):
	print(str(id) + " disconnected!")
	if local_id == 1:
		print("client disconnected!")
		connected_players.erase(id)
		if connected_players.size() < 4:
			peer.refuse_new_connections = false
		rpc("update_connections", connected_players)
	elif id == 1:
		# server closed
		print("server closed")
		close_connection()
		emit_signal("server_closed")


# TO SERVER CALLED
remote func client_connected(id, nn):
	# we are the server
	connected_players[id] = str(nn)
	if connected_players.size() >= 4:
		peer.refuse_new_connections = true
	rpc("update_connections", connected_players)

remote func player_ready(id):
	ready_players.push_back(id)
	if ready_players.size() == connected_players.size():
		ready_players = []
		ready_timeout.stop()
		print("telling all to start countdown")
		rpc("start_countdown")
func _on_ready_timout():
	for id in connected_players:
		if not ready_players.has(id):
			print(connected_players[id] + " couldnt load game!")
			close_connection()

# TO CLIENTS
remote func server_closed():
	print("server closed")
	emit_signal("server_closed")
	connected_players = {}
	if peer != null:
		peer.close_connection()

# TO EVERYONE (INCLUDING HOST)
remotesync func start_countdown():
	emit_signal("start_countdown")
remotesync func restart():
	emit_signal("restart_game")
remotesync func start(players):
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
remotesync func update_connections(players):
	connected_players = players
	emit_signal("update_connections", connected_players)
