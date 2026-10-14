extends Node2D


# --------------------------------------------------
# ESCENAS
# --------------------------------------------------
@export var obstacle_scene: PackedScene
@export var air_obstacle_scene: PackedScene
@export var dynamic_air_obstacle_scene: PackedScene


# --------------------------------------------------
# TEXTURAS
# --------------------------------------------------
@export var ground_textures: Array[Texture2D]
@export var ground_collision_sizes: Array[Vector2]
@export var ground_collision_offsets: Array[Vector2]

@export var air_textures: Array[Texture2D]
@export var air_collision_sizes: Array[Vector2]
@export var air_collision_offsets: Array[Vector2]

@export var dynamic_textures: Array[Texture2D]

# Para knife, peeler y whisk
@export var dynamic_collision_radii: Array[float]
@export var dynamic_collision_heights: Array[float]

# Para rolling_pin y spatula
@export var dynamic_collision_sizes: Array[Vector2]

# Posición de las formas dinámicas
@export var dynamic_collision_offsets: Array[Vector2]


# --------------------------------------------------
# POSICIÓN DE SPAWN
# --------------------------------------------------
@export var spawn_x: float = 1200.0
@export var spawn_y: float = 320.0


# --------------------------------------------------
# TIEMPOS
# --------------------------------------------------
@export var base_spawn_time: float = 1.55
@export var min_spawn_time: float = 0.95


# --------------------------------------------------
# VELOCIDAD
# --------------------------------------------------
@export var start_speed: float = 300.0
@export var max_speed: float = 420.0


# --------------------------------------------------
# DIFICULTAD
# --------------------------------------------------
@export var points_per_level: int = 8
@export var speed_step: float = 15.0
@export var spawn_step: float = 0.08


var current_spawn_time: float
var current_speed: float
var current_points: int = 0

var last_obstacle_type := ""


# --------------------------------------------------
# READY
# --------------------------------------------------
func _ready():

	randomize()

	current_spawn_time = base_spawn_time
	current_speed = start_speed

	spawn_loop()


# --------------------------------------------------
# LOOP DE SPAWN
# --------------------------------------------------
func spawn_loop():

	while true:

		spawn_obstacle()

		var variation := randf_range(-0.15, 0.15)

		var next_time := current_spawn_time + variation
		next_time = clamp(next_time, min_spawn_time, 2.2)

		await get_tree().create_timer(next_time).timeout


# --------------------------------------------------
# SPAWN OBSTÁCULOS
# --------------------------------------------------
func spawn_obstacle():

	if get_tree().paused:
		return

	var obstacle: Area2D = null
	var obstacle_type := "ground"


	# --------------------------------------------------
	# PROGRESIÓN DEL JUEGO
	# --------------------------------------------------

	if current_points < 10:

		obstacle_type = "ground"

	elif current_points < 20:

		if randf() < 0.30:
			obstacle_type = "air"
		else:
			obstacle_type = "ground"

	elif current_points < 35:

		var r = randf()

		if r < 0.55:
			obstacle_type = "ground"
		elif r < 0.85:
			obstacle_type = "air"
		else:
			obstacle_type = "dynamic"

	else:

		var r = randf()

		if r < 0.45:
			obstacle_type = "ground"
		elif r < 0.75:
			obstacle_type = "air"
		else:
			obstacle_type = "dynamic"


	# --------------------------------------------------
	# EVITAR REPETICIÓN EXCESIVA
	# --------------------------------------------------

	if obstacle_type == last_obstacle_type and randf() < 0.55:
		obstacle_type = "ground"

	last_obstacle_type = obstacle_type


	# --------------------------------------------------
	# DINÁMICO
	# --------------------------------------------------

	if obstacle_type == "dynamic":

		if dynamic_air_obstacle_scene == null:
			return

		obstacle = dynamic_air_obstacle_scene.instantiate()

		obstacle.position = Vector2(spawn_x, spawn_y - 40)

		assign_dynamic_texture(obstacle)


	# --------------------------------------------------
	# AÉREO
	# --------------------------------------------------

	elif obstacle_type == "air":

		if air_obstacle_scene == null:
			return

		obstacle = air_obstacle_scene.instantiate()

		var air_height: float

		if randf() < 0.5:
			air_height = randf_range(15.0, 35.0)
		else:
			air_height = randf_range(45.0, 70.0)

		obstacle.position = Vector2(spawn_x, spawn_y - air_height)

		assign_rectangle_texture(
			obstacle,
			air_textures,
			air_collision_sizes,
			air_collision_offsets
		)


	# --------------------------------------------------
	# TERRESTRE
	# --------------------------------------------------

	else:

		if obstacle_scene == null:
			return

		obstacle = obstacle_scene.instantiate()

		obstacle.position = Vector2(spawn_x, spawn_y)

		assign_rectangle_texture(
			obstacle,
			ground_textures,
			ground_collision_sizes,
			ground_collision_offsets
		)


	# --------------------------------------------------
	# VELOCIDAD
	# --------------------------------------------------

	if obstacle != null and "speed" in obstacle:
		obstacle.speed = current_speed

	add_child(obstacle)


# --------------------------------------------------
# TEXTURAS CON RECTANGLESHAPE2D
# --------------------------------------------------
func assign_rectangle_texture(
	node: Node,
	textures: Array,
	collision_sizes: Array[Vector2],
	collision_offsets: Array[Vector2]
):

	if textures.is_empty():
		return

	if not node.has_node("Sprite2D"):
		return

	var sprite := node.get_node("Sprite2D") as Sprite2D
	var index := randi() % textures.size()

	sprite.texture = textures[index]


	if node.has_node("CollisionShape2D"):

		var collision := node.get_node("CollisionShape2D") as CollisionShape2D

		if collision.shape is RectangleShape2D:

			# Cada instancia recibe su propia forma.
			collision.shape = collision.shape.duplicate()

			var rect := collision.shape as RectangleShape2D

			if index < collision_sizes.size():
				rect.size = collision_sizes[index]

			if index < collision_offsets.size():
				collision.position = collision_offsets[index]


# --------------------------------------------------
# TEXTURAS DINÁMICAS
# --------------------------------------------------
func assign_dynamic_texture(node: Node):

	if dynamic_textures.is_empty():
		return

	if not node.has_node("Sprite2D"):
		return

	var sprite := node.get_node("Sprite2D") as Sprite2D
	var index := randi() % dynamic_textures.size()

	sprite.texture = dynamic_textures[index]


	# --------------------------------------------------
	# BUSCAR LAS DOS FORMAS
	# --------------------------------------------------

	if not node.has_node("CollisionShapeCapsule"):
		return

	if not node.has_node("CollisionShapeRectangle"):
		return

	var capsule_collision := node.get_node(
		"CollisionShapeCapsule"
	) as CollisionShape2D

	var rectangle_collision := node.get_node(
		"CollisionShapeRectangle"
	) as CollisionShape2D


	# --------------------------------------------------
	# DESACTIVAR AMBAS PRIMERO
	# --------------------------------------------------

	capsule_collision.disabled = true
	rectangle_collision.disabled = true


	# --------------------------------------------------
	# KNIFE, PEELER, WHISK → CÁPSULA
	# --------------------------------------------------

	if index == 0 or index == 1 or index == 3:

		capsule_collision.disabled = false

		# Cada instancia recibe su propia forma.
		capsule_collision.shape = capsule_collision.shape.duplicate()

		if capsule_collision.shape is CapsuleShape2D:

			var capsule := capsule_collision.shape as CapsuleShape2D

			if index < dynamic_collision_radii.size():
				capsule.radius = dynamic_collision_radii[index]

			if index < dynamic_collision_heights.size():
				capsule.height = dynamic_collision_heights[index]

			if index < dynamic_collision_offsets.size():
				capsule_collision.position = dynamic_collision_offsets[index]


	# --------------------------------------------------
	# ROLLING PIN, SPATULA → RECTÁNGULO
	# --------------------------------------------------

	elif index == 2 or index == 4:

		rectangle_collision.disabled = false

		# Cada instancia recibe su propia forma.
		rectangle_collision.shape = rectangle_collision.shape.duplicate()

		if rectangle_collision.shape is RectangleShape2D:

			var rect := rectangle_collision.shape as RectangleShape2D

			if index < dynamic_collision_sizes.size():
				rect.size = dynamic_collision_sizes[index]

			if index < dynamic_collision_offsets.size():
				rectangle_collision.position = dynamic_collision_offsets[index]


# --------------------------------------------------
# SUMAR PUNTOS
# --------------------------------------------------
func add_point():

	current_points += 1

	if current_points % points_per_level == 0:
		increase_difficulty()


# --------------------------------------------------
# AUMENTAR DIFICULTAD
# --------------------------------------------------
func increase_difficulty():

	current_speed = min(
		current_speed + speed_step,
		max_speed
	)

	current_spawn_time = max(
		current_spawn_time - spawn_step,
		min_spawn_time
	)

	print(
		"Nivel ↑  Velocidad:",
		current_speed,
		" Spawn:",
		current_spawn_time
	)
