extends Node

#Script AUTOLOAD 
const SAVE_PATH := "user://settings.cfg"

var music_volume := 1.0
var sfx_enabled := true
var fullscreen_enabled := false

func _ready():

	load_settings()

	apply_settings()

# =========================
# APPLY
# =========================

func apply_settings():

	#MUSICA
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_volume)
	)

	#SFX
	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("SFX"),
		not sfx_enabled
	)

	#FULLSCREEN
	if fullscreen_enabled:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

# =========================
# SAVE
# =========================

func save_settings():

	var config = ConfigFile.new()

	config.set_value(
		"audio",
		"music_volume",
		music_volume
	)

	config.set_value(
		"audio",
		"sfx_enabled",
		sfx_enabled
	)

	config.set_value(
		"video",
		"fullscreen_enabled",
		fullscreen_enabled
	)

	config.save(SAVE_PATH)

# =========================
# LOAD
# =========================

func load_settings():

	var config = ConfigFile.new()

	var err = config.load(SAVE_PATH)

	if err == OK:

		music_volume = config.get_value(
			"audio",
			"music_volume",
			1.0
		)

		sfx_enabled = config.get_value(
			"audio",
			"sfx_enabled",
			true
		)

		fullscreen_enabled = config.get_value(
			"video",
			"fullscreen_enabled",
			false
		)

# =========================
# SETTERS
# =========================

func set_music_volume(value: float):

	music_volume = value

	apply_settings()

	save_settings()

func set_sfx_enabled(value: bool):

	sfx_enabled = value

	apply_settings()

	save_settings()

func set_fullscreen_enabled(value: bool):

	fullscreen_enabled = value

	apply_settings()

	save_settings()
