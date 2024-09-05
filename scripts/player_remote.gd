extends CharacterBody2D

class_name PlayerRemote

var target: Vector2

func _physics_process(delta: float) -> void:
	var diff := (target - global_position)
	var frame_diff := diff.length() / (PlayerLocal.MOVE_SPEED * delta)
	if frame_diff <= 1 or frame_diff >= 10:
		global_position = target
		velocity = Vector2.ZERO
	else:
		var dir := diff.normalized()
		velocity = dir * PlayerLocal.MOVE_SPEED
	
	%PlayerSprite.update_animation_from_velocity(velocity)
	
	move_and_slide()

func update_from_event(player_data: Dictionary) -> void:
	target = Vector2(
		player_data["position_x"],
		player_data["position_y"],
	)
	
	%PlayerSprite.modulate = player_data["color"]
	%PlayerLabel.text = str(player_data["id"])
