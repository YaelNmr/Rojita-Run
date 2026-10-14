extends Node2D

# --------------------------------------------------
# SAVE SYSTEM
# --------------------------------------------------
var high_score := 0
const SAVE_FILE := "user://savegame.dat"

# --------------------------------------------------
# GAME STATE
# --------------------------------------------------
var score := 0
var is_game_over := false
var new_hi_triggered := false
var hi_original_scale: Vector2
var is_paused := false

# --------------------------------------------------
# NODOS
# --------------------------------------------------
@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var game_over_label = $GameOverLabel
@onready var restart_label = $RestartLabel
@onready var back_label = $BackLabel
@onready var background = $Background
@onready var spawner = $Spawner
@onready var hi_sound: AudioStreamPlayer2D = $HiScoreSound


# --------------------------------------------------
# READY
# --------------------------------------------------
func _ready():

	add_to_group("game")

	load_high_score()

	score_label.text = "Score: 0"
	high_score_label.text = "HI: " + str(high_score)

	game_over_label.visible = false
	restart_label.visible = false

	game_over_label.modulate.a = 0.0
	restart_label.modulate.a = 0.0


	# outline (remarcado negro) para visibilidad SIEMPRE
	score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	score_label.add_theme_constant_override("outline_size", 4)
	
	high_score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	high_score_label.add_theme_constant_override("outline_size", 4)
	
	game_over_label.add_theme_color_override("font_outline_color", Color.BLACK)
	game_over_label.add_theme_constant_override("outline_size", 10)

	restart_label.add_theme_color_override("font_outline_color", Color.BLACK)
	restart_label.add_theme_constant_override("outline_size", 8)
	
	back_label.add_theme_color_override("font_outline_color", Color.BLACK)
	back_label.add_theme_constant_override("outline_size", 8)


	hi_original_scale = high_score_label.scale

	game_over_label.modulate = Color(1, 0.3, 0.3)   # rojo suave
	restart_label.modulate = Color(1, 1, 1)         # blanco limpio
	back_label.modulate = Color(1, 1, 1) 

	game_over_label.position += Vector2(2, 2) #sombra en el txt game over


# --------------------------------------------------
# SCORE
# --------------------------------------------------
func add_point():

	if is_game_over:
		return

	score += 1
	score_label.text = "Score: " + str(score)

	spawner.add_point()

	# SOLO se ejecuta cuando realmente supera el récord
	if score > high_score:

		high_score = score
		high_score_label.text = "HI: " + str(high_score)

		if not new_hi_triggered:
			new_hi_triggered = true
			play_new_hi_effect()


# --------------------------------------------------
# GAME OVER
# --------------------------------------------------
func game_over():

	if is_game_over:
		return

	is_game_over = true
	get_tree().paused = true

	await get_tree().create_timer(0.3).timeout

	game_over_label.visible = true
	restart_label.visible = true
	back_label.visible = true

	var tween := create_tween()

	#estado inicial
	game_over_label.scale = Vector2(0.5, 0.5)
	game_over_label.modulate.a = 0.0

	restart_label.scale = Vector2(0.8, 0.8)
	restart_label.modulate.a = 0.0

	back_label.scale = Vector2(0.8, 0.8)
	back_label.modulate.a = 0.0

	#GAME OVER (entrada fuerte)
	tween.tween_property(game_over_label, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(game_over_label, "scale", Vector2(1.3, 1.3), 0.2)\
	.set_trans(Tween.TRANS_BACK)\
	.set_ease(Tween.EASE_OUT)

	tween.tween_property(game_over_label, "scale", Vector2(1, 1), 0.15)

	#pequeña pausa entre mensajes
	tween.tween_interval(0.2)

	#RESTART (entrada suave)
	tween.tween_property(restart_label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(restart_label, "scale", Vector2(1, 1), 0.3)

	#BACK (entrada suave)
	tween.tween_property(back_label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(back_label, "scale", Vector2(1, 1), 0.3)

	save_high_score()


# --------------------------------------------------
# PAUSA
# --------------------------------------------------
func toggle_pause():

	is_paused = not is_paused
	get_tree().paused = is_paused

	$PauseLabel.visible = is_paused


# --------------------------------------------------
# PROCESS
# --------------------------------------------------
func _process(_delta):

	if is_game_over and Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()

# PAUSA
	if Input.is_action_just_pressed("pause") and not is_game_over:
		toggle_pause()

# VOLVER AL MENÚ tecla ESC
	if is_game_over and Input.is_action_just_pressed("ui_cancel"):

		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# --------------------------------------------------
# SAVE / LOAD
# --------------------------------------------------
func load_high_score():

	if FileAccess.file_exists(SAVE_FILE):

		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)

		if file:
			high_score = file.get_var()

		file.close()


func save_high_score():

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)

	if file:
		file.store_var(high_score)

	file.close()


# --------------------------------------------------
# HI SCORE EFFECT
# --------------------------------------------------
func play_new_hi_effect():

	var tween = create_tween()

	# color dorado
	high_score_label.modulate = Color(1, 0.9, 0.2)
	
	# escala basada en la ORIGINAL (esto es la clave)
	var big_scale = hi_original_scale * 1.3

	# pop de animación
	tween.tween_property(high_score_label, "scale", big_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(high_score_label, "scale", hi_original_scale, 0.2)

	await tween.finished

	# volver a normal
	high_score_label.scale = hi_original_scale
	high_score_label.modulate = Color(1, 1, 1)

	#sonido de new hi-score
	hi_sound.play()
