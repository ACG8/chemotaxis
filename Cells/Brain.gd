extends "res://Cells/Cell.gd"

var key = "A"

const KEYMAP = {
	"0": KEY_0, "1": KEY_1, "2": KEY_2, "3": KEY_3, "4": KEY_4,
	"5": KEY_5, "6": KEY_6, "7": KEY_7, "8": KEY_8, "9": KEY_9,
	"A": KEY_A, "B": KEY_B, "C": KEY_C, "D": KEY_D, "E": KEY_E,
	"F": KEY_F, "G": KEY_G, "H": KEY_H, "I": KEY_I, "J": KEY_J,
	"K": KEY_K, "L": KEY_L, "M": KEY_M, "N": KEY_N, "O": KEY_O,
	"P": KEY_P, "Q": KEY_Q, "R": KEY_R, "S": KEY_S, "T": KEY_T,
	"U": KEY_U, "V": KEY_V, "W": KEY_W, "X": KEY_X, "Y": KEY_Y,
	"Z": KEY_Z
}

func _input(event):
#	var text = get_node("LineEdit").text
#	var key = KEYMAP[text]
	if event is InputEventKey and event.scancode == KEYMAP[key]:
		if not is_active:
			rpc("activate")
	else:
		if is_active:
			rpc("deactivate")
#	if event.is_action_pressed(key):
#		rpc("activate")
#	if event.is_action_released(key):
#		rpc("deactivate")
