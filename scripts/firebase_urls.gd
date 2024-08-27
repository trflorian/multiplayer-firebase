extends Node

#const HOST: String = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
const HOST: String = "http://127.0.0.1"
const PORT: int = 8080

var BASE_URL = "%s:%d" % [HOST, PORT]

func get_player_url(player_id: int) -> String:
	return BASE_URL + ("/players/%d.json" % player_id)

func get_all_players_url() -> String:
	return BASE_URL + "/players.json"
