extends CharacterBody2D

class_name PlayerLocal

const SPAWN_RADIUS: float = 200
const MOVE_SPEED: float = 200

var player_id: int = randi_range(100000, 999999)
var player_color: Color = Color.from_hsv(randf(), 0.5, 1.0)

func _ready() -> void:
	%PlayerSprite.modulate = player_color
	%PlayerLabel.text = str(player_id)
	_set_random_spawn_pos()

func _set_random_spawn_pos() -> void:
	global_position = Vector2(
		randf_range(-SPAWN_RADIUS, SPAWN_RADIUS),
		randf_range(-SPAWN_RADIUS, SPAWN_RADIUS),
	)
	
func _physics_process(_delta: float) -> void:
	var dx = Input.get_axis("move_left", "move_right")
	var dy = Input.get_axis("move_up", "move_down")
	
	if dx != 0 or dy != 0:
		var dir = Vector2(dx, dy).normalized()
		velocity = dir * MOVE_SPEED
	else:
		velocity = Vector2.ZERO
	
	%PlayerSprite.update_animation_from_velocity(velocity)
	
	move_and_slide()
