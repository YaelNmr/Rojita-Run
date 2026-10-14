extends Control

const SAVE_FILE := "user://savegame.dat"

@onready var high_score_label = $HighScoreLabel
@onready var credits_panel = $CreditsPanel
@onready var click_sound = $ClickSound
@onready var apple_sprite = $AppleSprite2D
@onready var options_panel: Panel = $OptionsPanel


var high_score := 0


func _ready():

	load_high_score()
	high_score_label.text = "HI-SCORE: " + str(high_score)


	credits_panel.visible = false

	modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)
	
	options_panel.visible = false
	
	#oculta el botón Quit en la versión Web
	if OS.has_feature("web"):
		$QuitButton.visible = false


# -------------------------
#  ANIMACIÓN DE LA MANZANA
# -------------------------
func _process(_delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0

	#animacion de Rojita en el mainmenu
	apple_sprite.position.y = 160 + sin(t * 2.0) * 10 #flotación de la manzana

	#animación del título
	var title_scale = 1.0 + sin(t * 2.5) * 0.05
	$TitleLabel.scale = Vector2(title_scale, title_scale)

	#cambio de color suave del título
	var r = 1.0
	var g = 0.8 + sin(t * 1.3) * 0.2
	var b = 0.8 + sin(t * 1.7) * 0.2

	$TitleLabel.modulate = Color(r, g, b)

# -------------------------
# BOTONES
# -------------------------
func _on_play_button_pressed():
	click_sound.play()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	await tween.finished
	await get_tree().create_timer(0.2).timeout

	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_options_button_pressed() -> void:
	options_panel.visible = true


func _on_back_button_pressed() -> void:
	options_panel.visible = false


func _on_credits_button_pressed():
	credits_panel.visible = true


func _on_close_button_pressed():
	credits_panel.visible = false


func _on_quit_button_pressed():
	get_tree().quit()

# -------------------------
# SAVE
# -------------------------
func load_high_score():

	if FileAccess.file_exists(SAVE_FILE):

		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)

		if file:
			high_score = file.get_var()

		file.close()


# -------------------------
# HOVER EN BOTONES 
# -------------------------
#PLAY
func _on_play_button_mouse_entered():
	click_sound.play()
	animate_button($PlayButton, Vector2(1.1, 1.1))

func _on_play_button_mouse_exited():
	animate_button($PlayButton, Vector2(1, 1))

#OPTIONS
func _on_options_button_mouse_entered():
	click_sound.play()
	animate_button($OptionsButton, Vector2(1.1, 1.1))

func _on_options_button_mouse_exited():
	animate_button($OptionsButton, Vector2(1, 1))

#CREDITS
func _on_credits_button_mouse_entered() -> void:
	click_sound.play()
	animate_button($CreditsButton, Vector2(1.1, 1.1))

func _on_credits_button_mouse_exited() -> void:
	animate_button($CreditsButton, Vector2(1, 1))

#QUIT
func _on_quit_button_mouse_entered() -> void:
	click_sound.play()
	animate_button($QuitButton, Vector2(1.1, 1.1))

func _on_quit_button_mouse_exited() -> void:
	animate_button($QuitButton, Vector2(1, 1))

#ANIMACION DEL HOVER
func animate_button(button, scale_to):

	var tween = create_tween()
	tween.tween_property(button, "scale", scale_to, 0.1)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	button.add_theme_color_override("font_outline_color", Color.BLACK)
	button.add_theme_constant_override("outline_size", 3)
