extends Area2D

# distance between center of cell and origin of feature
# feature points away from center of cell
export var separation: int
var is_ghost = false
var is_valid_placement = false
onready var player: RigidBody2D = get_parent().get_parent()

func _ready():
	if is_ghost:
		get_node("Sprite").modulate = Color(0, 0, 1)
	else:
		connect("area_entered", self, "_destroy_if_overlapping")

func _process(delta):
	if is_ghost:
		var local_position= get_parent().get_local_mouse_position()
		position = local_position.normalized() * separation
		rotation = local_position.angle()

		var overlapping_areas = get_overlapping_areas()
		overlapping_areas.erase(get_parent().get_node("Area2D"))
		if overlapping_areas.size() == 0:
			is_valid_placement = true
			visible = true
		else:
			is_valid_placement = false
			visible = false

func _destroy_if_overlapping(area):
	if area == get_parent().get_node("Area2D") or area == self:
		return
	if area.get_network_master() != get_network_master():
		return

	if area.is_in_group("cells"):
		queue_free()
	if area.is_in_group("features") and not area.is_ghost:
		queue_free()
