extends Node

const host = "godot-firebase-test-game-default-rtdb.europe-west1.firebasedatabase.app"
const base_url = "https://%s" % host
const Utils = preload("res://scripts/utils.gd")

@onready var http: HTTPRequest = $HTTPRequest
@export var local_player_node : CharacterBody2D

var local_player_id = Utils.generate_random_player_name()
var local_player_color = Utils.generate_random_player_color()
var last_time_stamp = 0

var players = {}
var player_nodes = {}

var local_player = {}

var local_player_buffer = []

func _ready():
	local_player_node.set_color(local_player_color)
	local_player_node.set_player_name(local_player_id)
	get_tree().set_auto_accept_quit(false)
	
	await connect_player()
	start_player_stream()
	start_write_player()

	
func _process(_delta):
	var new_local_player = {
		"id": local_player_id,
		"px": local_player_node.position.x,
		"py": local_player_node.position.y,
		"col": local_player_color.to_html()
	}
	if new_local_player.hash() != local_player.hash():
		local_player = new_local_player
		local_player_buffer.append(new_local_player)
	
func _notification(what):
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		await disconnect_player()
		get_tree().quit()

func start_write_player():
	while true:
		if local_player_buffer.size() > 0:
			var curr_player_data = local_player_buffer[local_player_buffer.size() -1]
			local_player_buffer.clear()
			await write_player(local_player_id, curr_player_data)
		await get_tree().process_frame

func connect_player():
	print("Initializing player '%s' ..." % local_player_id)
	var player = {
		"id": local_player_id,
#		"timestamp": {
#			".sv": "timestamp"
#		}
	}
	await write_player(local_player_id, player)
	print("Player initialized!")
	
func disconnect_player():
	print("Disconnecting player '%s' ..." % local_player_id)
	await delete_player(local_player_id)
	print("Player disconnected!")
	
	
func start_player_stream():
	print("Connecting to host...")
	var tcp = StreamPeerTCP.new()
	var err = tcp.connect_to_host(host, 443)
	assert(err == OK) # Make sure connection is OK.
	
	while tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		tcp.poll()
		await get_tree().process_frame
	print("Conected: ", tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED)

	print("Connecting to stream...")
	var stream = StreamPeerTLS.new()
	err = stream.connect_to_stream(tcp, host, TLSOptions.client())
	print("Stream connect error: ", err)
	assert(err == OK) # Make sure connection is OK.
	
	while true:
		stream.poll()
		var status = stream.get_status()
		print("stream status: ", status)
		if status == StreamPeerTLS.STATUS_CONNECTED:
			break
		await get_tree().create_timer(0.1).timeout
	
	var request = "GET https://%s/players.json HTTP/1.1\n" % host
	request += "Host: %s\n" % host
	request += "Accept: text/event-stream\n\n"
	stream.put_data(request.to_utf8_buffer())
	
	var initialRequest = false
	while true:
		# Poll the stream to ensure connection is valid and check for availalbe bytes.
		stream.poll()
		var available_bytes: int = stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				printerr("Error getting data from stream: ", data[0])
			else:
				var response : String = data[1].get_string_from_utf8()
				if !initialRequest:
					if "HTTP/1.1 200 OK" not in response:
						printerr("Non-ok status code received from stream request: ", response)
					else:
						print("Stream started listening!")
						await load_all_players()
				else :
#					print(" --------  data:\n", response)
					process_event(response)
					
				initialRequest = true
		await get_tree().process_frame
	
	stream.disconnect_from_stream()
	tcp.disconnect_from_host()
	
func process_event(event_data: String):
	var lines = event_data.replace(" ", "").split("\n")
	var event = lines[0].split("event:")[1]
	var data = lines[1].split("data:")[1]
	var json = JSON.new()
	json.parse(data)
	var jsonData = json.get_data()
	
	if event != "put":
		print("unhandled event '%s' with data '%s'" % [event, data])
	else:
		var path = jsonData["path"]
		var id = path.split("/")[1]
		
		if id == "":
			return
		
		if id == local_player_id:
			return
		
		if id not in players:
			print("New player with id '%s' joined" % id)
		
		if id in players and jsonData["data"] == null:
			print("Player with id '%s' left" % id)
			players.erase(id)
		else:
			players[id] = jsonData["data"]
		sync_players()
	
func sync_players():
	
	for id in players:
		if id not in player_nodes:
			var node = load("res://scenes/enemy.tscn").instantiate()
			add_child(node)
			player_nodes[id] = node
		
		var pd = players[id]
		
		if pd is Dictionary:
			if "px" in pd and "py" in pd:
				player_nodes[id].set_target_position(Vector2(pd["px"], pd["py"]))
			
			if "col" in pd:
				player_nodes[id].set_color(Color(pd["col"]))
			
		player_nodes[id].set_player_name(id)
#		player_nodes[id].position.x = 
#		player_nodes[id].position.y = players[id]["py"]
		
	for id in player_nodes:
		if id not in players:
			player_nodes[id].queue_free()
			player_nodes.erase(id)
			break
	
	
func delete_player(player_id: String):
	http.cancel_request()
#	await http.request_completed
	http.request("%s/players/%s.json" % [base_url, player_id],
		[], HTTPClient.METHOD_DELETE)
	var _response = await http.request_completed

func write_player(player_id: String, data: Dictionary):
	http.request("%s/players/%s.json" % [base_url, player_id],
		[], HTTPClient.METHOD_PUT, JSON.stringify(data))
	var _response = await http.request_completed

func load_all_players():
	var req = "%s/players.json" % base_url
	http.request(req)
	var response = await http.request_completed
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var data = json.get_data()
	print("%s" % data)
	
	if data != null:
		for player_id in data:
			if player_id != local_player_id:
				players[player_id] = data[player_id]
				
	print("loaded players: ", players)
	sync_players()
		
func read_player(player_id: String):
	var req = "%s/players/%s.json" % [base_url, player_id]
	print(req)
	http.request(req)
	var response = await http.request_completed
	# result, status code, response headers, and body are now in indices 0, 1, 2, and 3 of response

	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var data = json.get_data()
	print("read player: %s" % data)
