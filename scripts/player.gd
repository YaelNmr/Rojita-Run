extends CharacterBody2D

const GRAVITY := 1200.0
const JUMP_FORCE := -430.0
const MAX_JUMP_HOLD_TIME := 0.12
const HOLD_GRAVITY_MULTIPLIER := 0.6

var jump_hold_timer: float = 0.0
var is_jumping: bool = false

@export var max_fall_speed := 900.0

@export var slice_scene: PackedScene
@export var slice_count := 3   # cantidad de gajos

@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound

func _ready():
	print("Player listo")
	print("HitSound es:", hit_sound)

func _physics_process(delta):

	if get_tree().paused:
		return

	# GRAVEDAD
	if not is_on_floor():
		if is_jumping and Input.is_action_pressed("jump") and jump_hold_timer < MAX_JUMP_HOLD_TIME:
			velocity.y += GRAVITY * HOLD_GRAVITY_MULTIPLIER * delta
			jump_hold_timer += delta
		else:
			velocity.y += GRAVITY * delta

		velocity.y = min(velocity.y, max_fall_speed)

	else:
		velocity.y = 0
		is_jumping = false
		jump_hold_timer = 0.0

	# SALTO
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_FORCE
		is_jumping = true
		jump_hold_timer = 0.0
		jump_sound.play()

	move_and_slide()


# ANIMACION MUERTE MANZANA
func die():

	$AnimatedSprite2D.visible = false

	for i in range(slice_count):

		var slice = slice_scene.instantiate()
		slice.global_position = global_position

		var dir = Vector2(
			randf_range(-1, 1),
			randf_range(-1.2, -0.5)
		).normalized()

		slice.velocity = dir * randf_range(200, 350)
		slice.rotation_speed = randf_range(-10, 10)

		get_parent().add_child(slice)

	hit_sound.play()
