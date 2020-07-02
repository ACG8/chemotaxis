extends CollisionShape2D

export (Array) onready var neighbors = []
var hexpos
var is_active = false

var color = Color(1, 1, 1)

signal activity_update

func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)

	if is_network_master():
		set_process_input(true)
		var area_2d = get_node("Area2D")
		area_2d.connect("clicked", self, "_on_clicked")
		area_2d.connect("unclicked", self, "_on_unclicked")
	else:
		set_process_input(false)

func _on_clicked():
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
