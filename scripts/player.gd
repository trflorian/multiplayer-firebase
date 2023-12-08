extends CharacterBody2D

const RANDOM_SPAWN_RADIUS: float = 100

@export var move_speed : float = 100
@export var starting_direction : Vector2 = Vector2(0, -1)

@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	global_position = Vector2(randf_range(-RANDOM_SPAWN_RADIUS, RANDOM_SPAWN_RADIUS), randf_range(-RANDOM_SPAWN_RADIUS, RANDOM_SPAWN_RADIUS))
	
	animation_tree.set("parameters/Idle/blend_position", starting_direction)

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	input_direction = input_direction.normalized()
	
	update_animation_parameters(input_direction)
	
	velocity = input_direction * move_speed
	
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

func set_player_name(player_name: String):
	label.text = player_name
	
func set_color(color: Color):
	sprite.modulate = color
