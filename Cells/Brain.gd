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

func _process(delta):
	if is_network_master():
		var key_pressed = Input.is_key_pressed(KEYMAP[key])
		if key_pressed and not is_active:
			activate()
		elif not key_pressed and is_active:
			deactivate()

func _input(event):
	if is_network_master():
		var area = get_node("Area2D")
		if area.is_clicked:
			var input_key = event.as_text()
			if input_key in KEYMAP:
				key = input_key
