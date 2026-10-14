extends Area2D

@export var speed: float = 300.0

func _physics_process(delta):
	if get_tree().paused:
		return

	position.x -= speed * delta

	# sale por la izquierda de la pantalla
	if position.x < -100:
		get_tree().call_group("game", "add_point")
		queue_free()


func _on_body_entered(body):
	if body.name == "Player":
		body.die()
		get_tree().call_group("game", "game_over")
