extends RigidBody2D

func _ready():
	pass

func compute_center_mass():
	var center_mass = Vector2.ZERO
	var cell_count = 0
	for node in get_children():
		if node.is_in_group("cells"):
			cell_count += 1
			center_mass += node.position
	return center_mass / cell_count

func _integrate_forces(state):
	var center_mass = compute_center_mass()
	if center_mass.length() > 1:
		print(center_mass.length())
		state.transform.origin += center_mass
		for node in get_children():
			if node.is_in_group("cells"):
				node.position -= center_mass

func _process(delta):
	compute_center_mass()

remotesync func die():
	self.visible = false

remotesync func respawn():
	var spawn
	if(self.get_network_master() == 1):
		spawn = get_parent().get_node("P1_Spawn")
	else:
		spawn = get_parent().get_node("P2_Spawn")

	self.position = spawn.position
	self.rotation = spawn.rotation
	self.visible = true
