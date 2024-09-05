extends Sprite2D

const ANIMATION_TIME := 200.0

enum LookDir {LEFT=8, RIGHT=12, UP=4, DOWN=0}

var curr_look_dir := LookDir.DOWN

var is_moving := false

func _process(_delta: float) -> void:
	var next_frame = int(curr_look_dir)
	if is_moving:
		next_frame += 2
	if int(Time.get_ticks_msec() / ANIMATION_TIME) % 2 == 0:
		next_frame += 1
	frame = next_frame

func update_animation_from_velocity(velocity: Vector2) -> void:
	is_moving = velocity.length() > 0
	
	if not is_moving:
		return
	
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x < 0:
			curr_look_dir = LookDir.LEFT
		else:
			curr_look_dir = LookDir.RIGHT
	else:
		if velocity.y < 0:
			curr_look_dir = LookDir.UP
		else:
			curr_look_dir = LookDir.DOWN
