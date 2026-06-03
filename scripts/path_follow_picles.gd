extends PathFollow3D

var velocidade_atual: float = 0.0

func _ready() -> void:
	jump_to_random_position()

func jump_to_random_position():
	progress = randi() % 5

func get_velocidade() -> Vector3:
	return Vector3(velocidade_atual, 0, 0)
