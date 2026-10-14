extends Node2D

@export var speed := 300.0

@onready var sprite_1 := $GroundSprite1
@onready var sprite_2 := $GroundSprite2

var sprite_width := 0.0

func _ready():
	sprite_width = sprite_1.texture.get_size().x * sprite_1.scale.x
	sprite_2.position.x = sprite_width

func _process(delta):
	if get_tree().paused:
		return

	sprite_1.position.x -= speed * delta
	sprite_2.position.x -= speed * delta

	if sprite_1.position.x <= -sprite_width:
		sprite_1.position.x = sprite_2.position.x + sprite_width

	if sprite_2.position.x <= -sprite_width:
		sprite_2.position.x = sprite_1.position.x + sprite_width
