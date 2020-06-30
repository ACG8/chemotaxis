extends "res://Cells/Cell.gd"

onready var player: RigidBody2D = get_parent()

func _physics_process(delta):

	var relative_position = global_transform.get_origin() - player.global_transform.get_origin()
	var relative_force = Vector2.UP.rotated(global_transform.get_rotation()) * 30

	player.apply_impulse(relative_position, relative_force * delta)
