extends TextureButton

var hexpos: Vector2

signal clicked(pos)

func _ready():
	connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	emit_signal("clicked", hexpos)

#func _input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
#		emit_signal("clicked", hexpos)
