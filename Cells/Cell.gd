extends CollisionShape2D

export (Array) onready var neighbors = []
var hexpos
var is_active = false
signal activated
signal deactivated


func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)

	if is_network_master():
		set_process_input(true)
	else:
		set_process_input(false)

remotesync func activate():
	is_active = true
	emit_signal("activated")

remotesync func deactivate():
	is_active = false
	emit_signal("deactivated")
