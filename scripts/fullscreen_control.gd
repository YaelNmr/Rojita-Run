extends CheckButton

func _ready():

	button_pressed = Settings.fullscreen_enabled

func _on_toggled(toggled_on):

	Settings.set_fullscreen_enabled(toggled_on)
