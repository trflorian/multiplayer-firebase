extends CharacterBody2D

class_name PlayerLocal

const MOVE_SPEED: float = 200

var player_id: int = randi_range(100000, 999999)
var player_color: Color = Color.from_hsv(randf(), 1.0, 1.0)

func _physics_process(delta: float) -> void:
	var dx = Input.get_axis("move_left", "move_right")
	var dy = Input.get_axis("move_up", "move_down")
	
	if dx != 0 or dy != 0:
		var dir = Vector2(dx, dy).normalized()
		velocity = dir * MOVE_SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
