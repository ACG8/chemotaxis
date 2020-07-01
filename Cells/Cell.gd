extends CollisionShape2D

export (Array) onready var neighbors = []
var hexpos

func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)

	if is_network_master():
		set_process_input(true)
	else:
		set_process_input(false)
