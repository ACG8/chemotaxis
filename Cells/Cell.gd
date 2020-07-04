extends CollisionShape2D

export (Array) onready var neighbors = []
var hexpos
var is_active = false
var color = Color(1, 1, 1)
var ghost_feature: Area2D
var player: RigidBody2D

signal activity_update

func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)

	var area_2d = get_node("Area2D")

	if is_network_master():
		area_2d.connect("clicked", self, "_on_clicked")
		area_2d.connect("unclicked", self, "_on_unclicked")
		area_2d.connect("mouse_entered", self, "_on_mouse_entered")
		area_2d.connect("mouse_exited", self, "_on_mouse_exited")
	else:
		area_2d.queue_free()

func _on_mouse_entered():
	var index = FeatureSingleton.feature_index

	if index < 0:
		return

	ghost_feature = FeatureSingleton.feature_list[index].instance()
	ghost_feature.is_ghost = true
	add_child(ghost_feature)

func _on_mouse_exited():
	if ghost_feature == null:
		return
	ghost_feature.queue_free()
	ghost_feature = null

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed and ghost_feature != null:
			ghost_feature.queue_free()
			ghost_feature = null


func _on_clicked():
	if ghost_feature != null and ghost_feature.is_valid_placement:
		rpc("create_feature", FeatureSingleton.feature_index, ghost_feature.transform)
	get_node("Sprite").modulate = Color(1, 0, 0)

func _on_unclicked():
	get_node("Sprite").modulate = color

remotesync func activate():
	is_active = true
	color = Color(0, 0, 1)
	get_node("Sprite").modulate = color
	emit_signal("activity_update")

remotesync func deactivate():
	is_active = false
	color = Color(1, 1, 1)
	get_node("Sprite").modulate = color
	emit_signal("activity_update")

remotesync func create_feature(index: int, tform: Transform2D):
	var feature: Area2D = FeatureSingleton.feature_list[index].instance()
	feature.transform = tform
	feature.player = player
	add_child(feature)
