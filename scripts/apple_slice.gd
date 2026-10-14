extends Node2D

@export var velocity := Vector2.ZERO
@export var gravity := 900.0
@export var rotation_speed := 5.0

func _physics_process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta
