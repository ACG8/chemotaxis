extends "res://Features/Feature.gd"

export var strength = 15
var is_active = true

func _physics_process(delta):

	if is_ghost:
		return

	var relative_position = global_transform.get_origin() - player.global_transform.get_origin()
	var relative_force = Vector2.UP.rotated(global_transform.get_rotation() - PI / 2) * 15

	if is_active:
		player.apply_impulse(relative_position, relative_force * delta)
