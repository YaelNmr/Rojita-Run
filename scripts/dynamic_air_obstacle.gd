extends Area2D

@export var speed: float = 300.0

# movimiento vertical
@export var float_amplitude: float = 70.0
@export var float_frequency: float = 4.0

var base_y: float
var time := 0.0


func _ready():
	print("Dynamic creado en:", position)
	base_y = position.y
	time = randf() * TAU  #Desfase aleatorio, no todos se mueven igual


func _physics_process(delta):

	if get_tree().paused:
		return

	rotation += delta * 2.0
	
	# Movimiento horizontal
	position.x -= speed * delta

	# Movimiento vertical tipo ola
	time += delta
	position.y = base_y + sin(time * float_frequency) * float_amplitude

	# Auto-destrucción
	if position.x < -100:
		get_tree().call_group("game", "add_point")
		queue_free()


func _on_body_entered(body):

	if body.name == "Player":
		body.die()
		get_tree().call_group("game", "game_over")
