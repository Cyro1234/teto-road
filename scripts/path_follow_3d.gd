extends PathFollow3D

# Velocidades limites (Mínima e Máxima) em metros por segundo
@export var velocidade_minima: float = 4.0   # Aumentei para 4.0 para não ficar lerdo
@export var velocidade_maxima: float = 8.0

var velocidade_atual: float = 4.0
var velocidade_vetor: Vector3 = Vector3.ZERO
var posicao_antiga: Vector3

func _ready() -> void:
	posicao_antiga = global_position
	# Sorteia uma velocidade inicial aleatória dentro do limite bom
	velocidade_atual = randf_range(velocidade_minima, velocidade_maxima)

func _process(delta: float) -> void:
	# Guarda o progresso antigo antes de mover
	var progresso_antigo = progress
	
	# Move o objeto ao longo do caminho
	progress += velocidade_atual * delta
	
	# DETECÇÃO DE LOOP: Se o progresso atual resetou ou voltou a ser menor que o anterior,
	# significa que ele completou uma volta e recomeçou do início!
	if progress < progresso_antigo:
		# Sorteia uma velocidade novinha para o próximo loop!
		velocidade_atual = randf_range(velocidade_minima, velocidade_maxima)
	
	# Calcula a velocidade física real do frame para o Teto herdar
	velocidade_vetor = (global_position - posicao_antiga) / delta
	posicao_antiga = global_position

# Função que o Teto chama para deslizar junto
func get_velocidade() -> Vector3:
	return velocidade_vetor
