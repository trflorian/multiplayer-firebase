extends CharacterBody2D

class_name PlayerRemote

var player_id: String
var color: Color

@export var speed: float = 100
@export var sprite: Sprite2D

var target_pos: Vector2

var is_initialized: bool = false

func _process(delta: float) -> void:
	var diff = target_pos - global_position
		
	if diff.length() < 1:
		global_position = target_pos
		velocity = Vector2.ZERO
	else:
		velocity = diff.normalized() * speed
		move_and_slide()

func update_from_event(player_data: Dictionary) -> void:
	player_id = str(player_data["player_id"])
	color = Color.html(player_data["color"])
	sprite.modulate = color
	_move_to_target(player_data["position_x"], player_data["position_y"])

func _move_to_target(target_pos_x, target_pos_y) -> void:
	target_pos = Vector2(target_pos_x, target_pos_y)
	
	if not is_initialized:
		global_position = target_pos
		is_initialized = true
