extends Node

const HOST: String = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"

func get_player_url(player_id: int) -> String:
	return HOST + ("/players/%d.json" % player_id)

func get_all_players_url() -> String:
	return HOST + "/players.json"
