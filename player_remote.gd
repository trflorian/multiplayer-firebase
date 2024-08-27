extends CharacterBody2D

class_name PlayerRemote

var player_id: String
var color: Color

func update_from_event(player_data: Dictionary) -> void:
	player_id = str(player_data["player_id"])
	color = Color.html(player_data["color"])
	_move_to_target(player_data["position_x"], player_data["position_y"])

func _move_to_target(target_pos_x, target_pos_y) -> void:
	global_position.x = target_pos_x
	global_position.y = target_pos_y
