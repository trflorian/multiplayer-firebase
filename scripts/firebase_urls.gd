extends Node

const HOST = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
 
func get_player_url(player_id) -> String:
	return HOST + ("/players/%s.json" % player_id)

func get_all_players_url() -> String:
	return HOST + "/players.json"
