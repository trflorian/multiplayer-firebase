extends Sprite2D

enum LookDir {LEFT=2, RIGHT=3, UP=1, DOWN=0}

@export var animation_speed: float = 5.0

var animation_time: float = 0.0
var curr_look_dir: LookDir = LookDir.DOWN

@onready var character: CharacterBody2D = get_parent()

func _process(delta: float) -> void:
	animation_time += delta
	
	var is_walking = character.velocity.length() > 0
	
	if is_walking:
		if abs(character.velocity.x) > abs(character.velocity.y):
			if character.velocity.x < 0:
				curr_look_dir = LookDir.LEFT
			if character.velocity.x > 0:
				curr_look_dir = LookDir.RIGHT
		else:
			if character.velocity.y < 0:
				curr_look_dir = LookDir.UP
			if character.velocity.y > 0:
				curr_look_dir = LookDir.DOWN
	
	frame = _get_sprite_frame(curr_look_dir, is_walking, int(animation_time * animation_speed) % 2)

func _get_sprite_frame(look_dir: LookDir, is_walking: bool, animation_frame: int) -> int:
	var sprite_frame = int(look_dir) * 4
	if is_walking:
		sprite_frame += 2
	sprite_frame += animation_frame
	return sprite_frame
