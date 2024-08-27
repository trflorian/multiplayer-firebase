extends CharacterBody2D

class_name PlayerLocal

const MOVE_SPEED: float = 100

@export var sprite: Sprite2D

var player_id: int = randi_range(100000, 999999)
var player_color: Color = Color.from_hsv(randf(), 0.5, 1.0)

func _ready() -> void:
	_set_random_spawn()
	
	sprite.modulate = player_color

func _set_random_spawn() -> void:
	var spawn_radius = 50
	var rand_x = randf_range(-spawn_radius, spawn_radius)
	var rand_y = randf_range(-spawn_radius, spawn_radius)
	global_position = global_position + Vector2(rand_x, rand_y)

func _physics_process(_delta: float) -> void:
	var dx = Input.get_axis("move_left", "move_right")
	var dy = Input.get_axis("move_up", "move_down")
	
	if dx != 0 or dy != 0:
		var dir = Vector2(dx, dy).normalized()
		velocity = dir * MOVE_SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
