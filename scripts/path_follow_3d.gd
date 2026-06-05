extends PathFollow3D

var velocidade := 4.0
var velocidade_vetor := Vector3.ZERO

func _ready():
	# Começa com uma velocidade aleatória pra não ficar tudo igual
	velocidade = randf_range(4.0, 8.0)

func _physics_process(delta):
	var pos_antiga = global_position
	progress += velocidade * delta # Anda no caminho
	
	# Gambiarra matemática pra saber a velocidade real do frame e passar pro Player
	velocidade_vetor = (global_position - pos_antiga) / delta

	if progress_ratio >= 0.99:
		velocidade = randf_range(4.0, 8.0) # Sorteia de novo quando dá a volta

func get_velocidade():
	return velocidade_vetor
