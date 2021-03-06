extends RigidBody2D

const HEX_BASIS_A = Vector2(0, -1)
const HEX_BASIS_B = Vector2(sqrt(3) * 0.5, -0.5)
const HEX_GRID_SIZE = 128
const CELL_SEPARATION = 64

var nucleus
var cells: Dictionary
export var packed_feature_menu: PackedScene
export var packed_stub: PackedScene
export (Array, PackedScene) var packed_cells

enum {
	CELL,
	CELL_NEURON,
	CELL_FLAGELLUM,
}

puppet var target_transform
puppet var target_velocity
const LERP_SPEED = 5

func _ready():
	# initialize cells

	nucleus = add_cell(CELL, Vector2(0, 0))
	var b1 = add_cell(CELL, Vector2(0, -1))
	var b2 = add_cell(CELL, Vector2(-1, 1))
	var b3 = add_cell(CELL, Vector2(-1, 0))
	add_cell(CELL, Vector2(-1, -1))
	add_cell(CELL, Vector2(-2, 1))
	add_cell(CELL, Vector2(-2, 0))

#	b1.key = "D"
#	b2.key = "A"
#	b3.key = "W"

	if is_network_master():
#		get_node("Camera2D").make_current()
		var feature_menu = packed_feature_menu.instance()
		add_child(feature_menu)
	else:
		set_process_input(false)

func _physics_process(delta):
	if is_network_master():
		rset_unreliable("target_transform", transform)
		rset_unreliable("target_velocity", linear_velocity)

func get_neighbors(pos: Vector2):
	# UP, UP-RIGHT, DOWN-RIGHT, DOWN, DOWN-LEFT, UP-LEFT
	var up = Vector2(1, 0)
	var up_rt = Vector2(0, 1)
	var dn_rt = Vector2(-1, 1)
	var dn = Vector2(-1, 0)
	var dn_lt = Vector2(0, -1)
	var up_lt = Vector2(1, -1)
	return [pos + up, pos + up_rt, pos + dn_rt, pos + dn, pos + dn_lt, pos + up_lt]

func get_neighbor_cells(cell):
	var hexpos = cell.hexpos
	var neighbors = []
	for vec in get_neighbors(hexpos):
		if cells.has(vec.round()):
			neighbors.append(cells[vec.round()])
	return neighbors

func get_open_neighbors(cell):
	var hexpos = cell.hexpos
	var neighbors = []
	for vec in get_neighbors(hexpos):
		if not cells.has(vec.round()):
			neighbors.append(vec)
	return neighbors

func get_open_surroundings():
	var connected_cells = get_connected_cells()
	var open_surroundings = []
	for cell in connected_cells:
		var open_neighbors = get_open_neighbors(cell)
		for vec in open_neighbors:
			if not vec.round() in open_surroundings:
				open_surroundings.append(vec.round())
	return open_surroundings

func get_connected_cells():
	var connected_cells = []
	var unexamined_cells = [nucleus]
	while unexamined_cells.size() > 0:
		var cell = unexamined_cells[0]
		for neighbor in get_neighbor_cells(cell):
			if not neighbor in connected_cells and not neighbor in unexamined_cells:
				unexamined_cells.append(neighbor)
		connected_cells.append(cell)
		unexamined_cells.remove(0)
	return connected_cells

remotesync func add_cell(index: int, hexpos: Vector2):
	var cell = packed_cells[index].instance()
	cells[hexpos.round()] = cell
	var origin = Vector2(0, 0)
	if nucleus != null:
		origin = nucleus.position
	cell.position = (hexpos.x * HEX_BASIS_A + hexpos.y * HEX_BASIS_B) * CELL_SEPARATION + origin
	cell.hexpos = hexpos
	cell.player = self
	cell.set_network_master(get_network_master())
	add_child(cell)
	# connect to control cells
	if is_network_master():
		if cell.is_in_group("neurons"):
			cell.connect("activity_update", self, "_update_activity")
	return cell

func _update_activity():
	for cell in cells.values():
		if not cell.is_in_group("neurons"):
			update_active_state(cell)

func update_active_state(cell):
	var active_neuron = false
	for neighbor in get_neighbor_cells(cell):
		if neighbor.is_in_group("neurons") and neighbor.is_active:
			active_neuron = true
			break
	if cell.is_active and not active_neuron:
		cell.rpc("deactivate")
		return
	if not cell.is_active and active_neuron:
		cell.rpc("activate")
		return

func create_blank_cell(hexpos):
	rpc("add_cell", CELL, hexpos)
	clear_stubs()
	display_stubs()

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
		state.transform.origin += center_mass
		for node in get_children():
			if node.is_in_group("cells"):
				node.position -= center_mass
			elif node.is_in_group("ui"):
				node.rect_position -= center_mass

	if not is_network_master():
		state.set_linear_velocity(
			state.get_linear_velocity().linear_interpolate(
				target_velocity, state.get_step()
			)
		)

		state.transform = state.transform.interpolate_with(
			target_transform, state.get_step()
		)

func display_stub(hexpos: Vector2):
	var stub = packed_stub.instance()
	var origin = nucleus.position
	var realpos = (hexpos.x * HEX_BASIS_A + hexpos.y * HEX_BASIS_B) * CELL_SEPARATION
	stub.rect_position = realpos - stub.rect_size / 2 + origin
	stub.hexpos = hexpos
	add_child(stub)
	stub.connect("clicked", self, "create_blank_cell")

func display_stubs():
	var open_positions = get_open_surroundings()
	for hexpos in open_positions:
		display_stub(hexpos)

func clear_stubs():
	for node in get_children():
		if node.is_in_group("ui"):
			node.queue_free()

func _input(event):
	if Input.is_action_just_pressed("ui_select"):
		display_stubs()
	if Input.is_action_just_released("ui_select"):
		clear_stubs()

remotesync func die():
	self.visible = false

remotesync func respawn():
	var spawn
	if self.get_network_master() == 1:
		spawn = get_parent().get_node("P1_Spawn")
	else:
		spawn = get_parent().get_node("P2_Spawn")

	self.position = spawn.position
	self.rotation = spawn.rotation
	self.visible = true
