extends CheckButton

func _ready():

	button_pressed = Settings.sfx_enabled

func _on_toggled(toggled_on):

	Settings.set_sfx_enabled(toggled_on)
