extends Node

const HOST = "godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
const HOST_URL = "https://" + HOST
 
func get_player_url(player_id) -> String:
	var path_player = "/players/%s.json" % player_id
	return HOST_URL + path_player

func get_players_url() -> String:
	return HOST_URL + "/players.json"
