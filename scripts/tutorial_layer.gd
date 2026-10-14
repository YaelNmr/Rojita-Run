extends CanvasLayer

@onready var tutorial_label = $TutorialLabel

func _ready():
	show_tutorial("SPACE to JUMP
ENTER to PAUSE", 4.0)

func show_tutorial(texto, duracion):
	tutorial_label.text = texto
	tutorial_label.visible = true
	
	await get_tree().create_timer(duracion).timeout
	
	tutorial_label.visible = false
