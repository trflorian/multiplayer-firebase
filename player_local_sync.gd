extends HTTPRequest

@export var player: PlayerLocal
var prev_player_data_json: String
var is_request_pending: bool = false

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	request_completed.connect(_on_request_completed)
	
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if result != RESULT_SUCCESS:
		printerr("request failed with response code %d" % response_code)
	is_request_pending = false

func _process(delta: float) -> void:
	if !is_request_pending:
		_send_local_player()

func _get_player_url() -> String:
	const host = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
	var path_player = "/players/%s.json" % player.player_id
	return host + path_player

func _send_local_player() -> void:
	var url = _get_player_url()
	var player_data = {
		"player_id": player.player_id,
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"color": player.player_color.to_html(false)
	}
	var player_data_json = JSON.stringify(player_data)
	
	if player_data_json == prev_player_data_json:
		# don't send data if nothing has changed
		return
	
	prev_player_data_json = player_data_json
	
	is_request_pending = true
	request(url, [], HTTPClient.METHOD_PUT, player_data_json)

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_delete_local_player()

func _delete_local_player() -> void:
	var url = _get_player_url()
	cancel_request()
	request(url, [], HTTPClient.METHOD_DELETE, "")
	await request_completed
	get_tree().quit()
	
