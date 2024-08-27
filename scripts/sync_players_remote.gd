extends Node2D

@export var player_local: PlayerLocal
@export var player_remote_scene: PackedScene

var http_client := HTTPClient.new()

var players_remote: Dictionary = {}

func _ready() -> void:
	_setup_connection()

func _setup_connection() -> void:
	http_client.connect_to_host(FirebaseUrls.HOST, FirebaseUrls.PORT)
	
	var status = http_client.get_status()
	while status in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING]:
		http_client.poll()
		status = http_client.get_status()
	
	if status != HTTPClient.STATUS_CONNECTED:
		printerr("Cannot connect to Firebase: %d" % status)
		return
	
	http_client.request(
		HTTPClient.METHOD_GET,
		FirebaseUrls.get_all_players_path(),
		["Accept: text/event-stream"],
	)
	
	print("Connection successful!")

func _process(_delta: float) -> void:
	_check_for_new_events()

func _check_for_new_events() -> void:
	http_client.poll()
	if not http_client.has_response():
		return
	
	var body = http_client.read_response_body_chunk()
	if not body:
		return
	
	var response = body.get_string_from_utf8()
	var events = _parse_response_event_data(response)
	
	for event in events:
		_handle_player_event(event)

func _handle_player_event(event: Dictionary) -> void:
	var path = event["path"]
	var data = event["data"]
	
	if path == "/":
		if data != null:
			for player_id in data.keys():
				_create_or_update_player(player_id, data[player_id])
		for player_id in players_remote.keys():
			if data == null or player_id not in data.keys():
				_delete_player(player_id)
	else:
		var player_id = path.split("/")[-1]
		if data == null:
			_delete_player(player_id)
		else:
			_create_or_update_player(player_id, data)

func _create_or_update_player(player_id: String, player_data: Dictionary) -> void:
	if player_id == str(player_local.player_id):
		return
	
	var player: PlayerRemote
	if player_id in players_remote:
		player = players_remote[player_id]
	else:
		player = player_remote_scene.instantiate()
		add_child(player)
	
	player.update_from_event(player_data)
	players_remote[player_id] = player

func _delete_player(player_id: String) -> void:
	if player_id == str(player_local.player_id):
		return
		
	if player_id not in players_remote:
		return
	
	var player = players_remote[player_id]
	player.queue_free()
	
	players_remote.erase(player_id)

func _parse_response_event_data(response: String) -> Array[Dictionary]:
	var response_parts = response.replace("\r", "").split("\n\n")
	var event_data: Array[Dictionary] = []
	for response_part in response_parts:
		var event = _parse_event_data(response_part)
		if event == null:
			continue
		if event.type != "put":
			continue
		event_data.append(event.data)
	return event_data

class ServerSentEvent:
	var type: String
	var data: Dictionary

const EVENT_TYPE_PREFIX = "event: "
const EVENT_DATA_PREFIX = "data: "

func _parse_event_data(response_part: String) -> ServerSentEvent:
	# event: [NAME_OF_EVENT]
	# data: [JSON_PAYLOAD]
	
	var event_lines = response_part.split("\n")
	if event_lines.size() != 2:
		return null

	var event_type_line = event_lines[0]
	if !event_type_line.begins_with(EVENT_TYPE_PREFIX):
		return null
	var event_data_line = event_lines[1]
	if !event_data_line.begins_with(EVENT_DATA_PREFIX):
		return null

	var event_type_str = event_type_line.substr(EVENT_TYPE_PREFIX.length())
	var event_data_str = event_data_line.substr(EVENT_DATA_PREFIX.length())
	
	var event_data_json = JSON.parse_string(event_data_str)
	if event_data_json == null:
		event_data_json = {}
	
	var event = ServerSentEvent.new()
	event.type = event_type_str
	event.data = event_data_json
	
	return event
