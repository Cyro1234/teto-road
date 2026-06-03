extends PathFollow3D

# Velocidades limites
@export var velocidade_minima: float = 4.0
@export var velocidade_maxima: float = 8.0

var velocidade_atual: float = 4.0
var velocidade_vetor: Vector3 = Vector3.ZERO

func _ready() -> void:
	velocidade_atual = randf_range(
		velocidade_minima,
		velocidade_maxima
	)

func _physics_process(delta: float) -> void:

	# salva posição antes de mover
	var posicao_anterior = global_position

	# move na path
	progress += velocidade_atual * delta

	# calcula velocidade REAL do frame
	velocidade_vetor = (
		global_position - posicao_anterior
	) / delta

	# quando completar loop sorteia velocidade nova
	if progress_ratio >= 0.99:
		velocidade_atual = randf_range(
			velocidade_minima,
			velocidade_maxima
		)

# player chama isso
func get_velocidade() -> Vector3:
	return velocidade_vetor
