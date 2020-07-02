extends "res://Cells/Cell.gd"

onready var player: RigidBody2D = get_parent()
export var strength = 15

func _physics_process(delta):

	var relative_position = global_transform.get_origin() - player.global_transform.get_origin()
	var relative_force = Vector2.UP.rotated(global_transform.get_rotation()) * 15

	if is_active:
		player.apply_impulse(relative_position, relative_force * delta)
