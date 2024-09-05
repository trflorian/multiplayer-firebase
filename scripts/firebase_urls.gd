extends Node

# For a real Firebase Realtime Database
const HOST: String = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
const PORT: int = 443

# For local Realtime Database mock server, see https://github.com/trflorian/realtimedb-local-server
#const HOST: String = "http://localhost"
#const PORT: int = 8000

func get_player_url(player_id: int) -> String:
	var base_url = "%s:%d" % [HOST, PORT]
	return base_url + ("/players/%d.json" % player_id)

func get_all_players_route() -> String:
	return "/players.json"
