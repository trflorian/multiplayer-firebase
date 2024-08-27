extends HTTPRequest

@export var player: PlayerLocal

var is_request_pending: bool = false
var prev_player_data_json: String

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	request_completed.connect(_on_request_completed)

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_delete_local_player()

func _delete_local_player() -> void:
	var url = FirebaseUrls.get_player_url(player.player_id)
	cancel_request()
	request(url, [], HTTPClient.METHOD_DELETE, "")
	await request_completed
	get_tree().quit()

func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray,
) -> void:
	if result != RESULT_SUCCESS:
		printerr("request failed with result %d" % result)
	is_request_pending = false

func _process(_delta: float) -> void:
	if not is_request_pending:
		_send_local_player()

func _send_local_player() -> void:
	var player_data = {
		"id": player.player_id,
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"color": player.player_color.to_html(false),
		#"timestamp": Time.get_unix_time_from_system(),
	}

	var player_data_json = JSON.stringify(player_data)
	if player_data_json == prev_player_data_json:
		return
	prev_player_data_json = player_data_json

	var url = FirebaseUrls.get_player_url(player.player_id)

	is_request_pending = true
	request(url, [], HTTPClient.METHOD_PUT, player_data_json)
