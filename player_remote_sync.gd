extends Node

const EVENT_TYPE_PREFIX = "event: "
const EVENT_DATA_PREFIX = "data: "

class EventData:
	var type: String
	var data: Dictionary

func _ready() -> void:
	_start_listening()

func _start_listening() -> void:
	var tcp = await _setup_tcp_stream()
	var stream = await _setup_tls_stream(tcp)
	
	_start_sse_stream(stream)
	
	while true:
		var response = await _read_stream_response(stream)
		var events = _parse_response_event_data(response)
		for event in events:
			print(event)

func _setup_tcp_stream() -> StreamPeerTCP:
	var tcp = StreamPeerTCP.new()
	
	var err_conn_tcp = tcp.connect_to_host(FirebaseUrls.HOST, 443)
	assert(err_conn_tcp == OK)
	
	tcp.poll()
	var tcp_status = tcp.get_status()
	while tcp_status != StreamPeerTCP.STATUS_CONNECTED:
		await get_tree().process_frame
		tcp.poll()
		tcp_status = tcp.get_status()
	
	return tcp

func _setup_tls_stream(tcp: StreamPeerTCP) -> StreamPeerTLS:
	var stream = StreamPeerTLS.new()
	
	var err_conn_stream = stream.connect_to_stream(tcp, FirebaseUrls.HOST)
	assert(err_conn_stream == OK)
	
	stream.poll()
	var stream_status = stream.get_status()
	while stream_status != StreamPeerTLS.STATUS_CONNECTED:
		await get_tree().process_frame
		stream.poll()
		stream_status = stream.get_status()
	
	return stream

func _start_sse_stream(stream: StreamPeer) -> void:
	var url = FirebaseUrls.get_players_url()
	var request_line = "GET %s HTTP/1.1" % url
	var headers = [
		"Host: %s" % FirebaseUrls.HOST,
		"Accept: text/event-stream",
	]
	var request = ""
	request += request_line + "\n" # request line
	request += "\n".join(headers) + "\n" # headers
	request += "\n" # empty line 
	stream.put_data(request.to_ascii_buffer())

func _read_stream_response(stream: StreamPeer) -> String:
	stream.poll()
	var available_bytes = stream.get_available_bytes()
	while available_bytes == 0:
		await get_tree().process_frame
		stream.poll()
		available_bytes = stream.get_available_bytes()
		
	return stream.get_string(available_bytes)

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
