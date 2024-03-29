extends CharacterBody2D

class_name Enemy

@export var move_speed : float = 100

@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var target_pos = Vector2()

func _physics_process(_delta):
	var dir = target_pos - position
	
	if dir.length() < 1:
		position = target_pos
		dir = Vector2()
	elif dir.length() > 40:
		position = target_pos
		dir = Vector2()
	else:
		dir = dir.normalized()
	
	update_animation_parameters(dir)
	
	velocity = dir * move_speed
	
	move_and_slide()
	
	pick_new_state()

func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Walk/blend_position", move_input)

func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func set_target_position(target_position: Vector2):
	target_pos = target_position
	
func set_player_name(player_name: String):
	label.text = player_name

func set_color(color: Color):
	sprite.modulate = color
