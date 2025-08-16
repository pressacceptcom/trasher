extends Button

var tcc1014

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tcc1014 = get_parent()
	connect('pressed', self, '_button_pressed')

func _button_pressed():
	tcc1014.video_resolution_register.register = Tcc1014.GraphicsResolution.THREE_TWENTY_16 | Tcc1014.LinesPerField.TWO_TWENTY_FIVE

