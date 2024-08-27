extends Node

const EVENT_TYPE_PREFIX = "event: "
const EVENT_DATA_PREFIX = "data: "

class EventData:
	var type: String
	var data: Dictionary

@export var player_remote_scene: PackedScene

@export var player_local: PlayerLocal
var players_remote: Dictionary = {}

var client = HTTPClient.new()

func _ready() -> void:
	_setup_connection()

func _setup_connection() -> void:
	client.connect_to_host(FirebaseUrls.HOST)

	# Wait for the connection
	var status = client.get_status()
	while status in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING]:
		client.poll()
		status = client.get_status()
	
	if status != HTTPClient.STATUS_CONNECTED:
		printerr("Cannot connect to Firebase: %d" % status)
		return

	client.request(
		HTTPClient.METHOD_POST,
		FirebaseUrls.get_all_players_url(),
		["Accept: text/event-stream"],
	)

func _process(_delta: float) -> void:
	_check_for_new_events()

func _check_for_new_events() -> void:
	client.poll()
	if not client.has_response():
		return
	
	var body = client.read_response_body_chunk()
	if not body:
		return
	
	var response = body.get_string_from_utf8()
	var events = _parse_response_event_data(response)
	for event in events:
		_handle_player_event(event)

func _create_or_update_player(player_id: String, player_data: Dictionary):
	if player_id == str(player_local.player_id):
		return

	var player: PlayerRemote
	if player_id in players_remote:
		player = players_remote[player_id]
	else:
		player = player_remote_scene.instantiate()
		get_parent().add_child(player)

	player.update_from_event(player_data)
	players_remote[player_id] = player

func _delete_player(player_id: String):
	if player_id == str(player_local.player_id):
		return

	if player_id not in players_remote:
		return

	var player = players_remote[player_id] as PlayerRemote
	player.queue_free()

func _handle_player_event(event: Dictionary):
	var path = event["path"] as String
	var data = event["data"]

	if path == "/":
		if data != null:
			for player_id in data.keys():
				_create_or_update_player(player_id, data[player_id])
		for player_id in players_remote.keys():
			if data == null or player_id not in data.keys():
				_delete_player(player_id)
	else:
		var path_parts = path.split("/")
		var player_id = path_parts[-1]
		if data != null:
			_create_or_update_player(player_id, data)
		else:
			_delete_player(player_id)

func _parse_event_data(event_str: String) -> EventData:
	# event: event name
	# data: JSON encoded data payload

	var event_lines = event_str.split("\n")
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

	var event = EventData.new()
	event.type = event_type_str
	event.data = event_data_json
	return event

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
