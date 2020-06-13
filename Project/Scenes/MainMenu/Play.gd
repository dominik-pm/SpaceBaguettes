extends Control

# menus
onready var menu = $PlayMenu
onready var offline = $PlayOfflineMenu
onready var online = $PlayOnlineMenu

# other
onready var ip_input = $PlayMenu/VBoxContainer/OnlineContainer/IPContainer/IPInput
onready var name_input = $PlayMenu/VBoxContainer/OnlineContainer/NameInput

func _ready():
	menu.show()
	offline.hide()
	online.hide()
	
	Network.connect("server_closed", self, "_on_server_closed")
	Network.connect("failed_to_join", self, "_on_network_failed")

func show():
	init_menu()
	visible = true

func hide():
	visible = false

func init_menu():
	if not online.visible:
		$PlayMenu/VBoxContainer/OfflineContainer/Offline.grab_focus()
		menu.show()
		offline.hide()
		online.hide()

func _on_server_closed():
	init_menu()

func _on_network_failed():
	online.hide()
	init_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if menu.visible:
			get_parent()._on_BtnBack_pressed()
		elif online.visible:
			online.hide()
			init_menu()
			Network.close_connection()
		else:
			init_menu()

func _on_offline_pressed():
	menu.hide()
	offline.show()
	$PlayOfflineMenu/VBox/Control/BtnStart.grab_focus()

func _on_host_pressed():
	var nn = name_input.text
	
	if nn.length() > 0:
		# name is valid
		name_input.modulate = Color(1, 1, 1)
		
		menu.hide()
		online.show()
		Network.host_game(nn)
	else:
		name_input.modulate = Color(1, 0, 0)

func _on_join_pressed():
	var ip = ip_input.text
	var nn = name_input.text
	
	if nn.length() > 0:
		# name is valid
		name_input.modulate = Color(1, 1, 1)
		var checked_ip = check_ip(ip)
		if checked_ip != null:
			# ip is also valid
			ip_input.modulate = Color(1, 1, 1)
			
			menu.hide()
			online.show()
			Network.join_game(nn, checked_ip)
		else:
			ip_input.modulate = Color(1, 0, 0)
	else:
		name_input.modulate = Color(1, 0, 0)


func check_ip(ip):
	if ip in ["localhost", "l", ""]:
		return "127.0.0.1"
	
	var regex = RegEx.new()
	regex.compile("\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b")
	var result = regex.search(ip)
	
	# if the ip is not valid, return null
	if not result:
		return null
	# else return the ip
	return ip
