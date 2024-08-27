extends Node

const HOST: String = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
const PORT: int = 443

#const HOST: String = "http://127.0.0.1"
#const PORT: int = 8000

var URL := "%s:%d" % [HOST, PORT]

func get_player_url(player_id: int) -> String:
	return URL + ("/players/%d.json" % player_id)

func get_all_players_path() -> String:
	return "/players.json"
