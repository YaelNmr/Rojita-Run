extends HSlider

func _ready():

	min_value = 0
	max_value = 1
	step = 0.01

	value = Settings.music_volume

func _on_value_changed(_value):

	Settings.set_music_volume(_value)
