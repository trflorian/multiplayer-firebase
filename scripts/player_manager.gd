extends Node

class_name PlayerManager

const Utils = preload("res://scripts/utils.gd")

@export var local_player_node : CharacterBody2D

var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

var local_player_id = Utils.generate_random_player_name()
var local_player_color = Utils.generate_random_player_color()

func _ready() -> void:
	local_player_node.set_color(local_player_color)
	local_player_node.set_player_name(local_player_id)

func spawn_enemy() -> Enemy:
	var node = enemy_scene.instantiate() as Enemy
	add_child(node)
	return node
