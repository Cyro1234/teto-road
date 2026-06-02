extends Node3D

# Carrega as cenas dos módulos
@export var cena_grama: PackedScene = preload("res://cenas/partes/grama.tscn")
@export var cena_grama_escura: PackedScene = preload("res://cenas/partes/grama_escura.tscn")
@export var cena_rio: PackedScene = preload("res://cenas/partes/rio.tscn")
@export var cena_rio_invertido: PackedScene = preload("res://cenas/partes/rio_invertido.tscn")
@export var cena_rio_picles: PackedScene = preload("res://cenas/partes/rio_picles.tscn")
@export var cena_rua: PackedScene = preload("res://cenas/partes/rua.tscn")

# Configurações do Grid e do tamanho do Mapa
@export var quantidade_faixas_na_tela := 40 # Quantas faixas ficam visíveis por vez
@export var limite_passos_atras := 5 # Quantos passos ele pode voltar antes de morrer

# Variáveis de controle do sistema infinito
var faixas_vivas: Array[Node3D] = []
var proximo_z := 0
var ultimo_tipo := "grama"
var player_nodo: CharacterBody3D = null

# Variáveis para a mecânica de morte por recuo
var maior_linha_alcancada := 0 # Guarda o Z mais distante (em coordenadas positivas de passos)

# Referência para o texto de pontuação na tela ---
@onready var score_label = $CanvasLayer/ScoreLabel

func _ready() -> void:
	randomize()
	
	# Busca o jogador dinamicamente na cena
	player_nodo = get_tree().get_first_node_in_group("player")
	
	# Conecta o sinal do jogador para atualizar a interface ---
	if player_nodo != null:
		# Avisa o jogo para rodar a função atualizar_texto_score sempre que o sinal for emitido
		player_nodo.pontuacao_atualizada.connect(atualizar_texto_score)
	
	# 1. Configura o ponto inicial da construção lá atrás no Z = 8 positivo
	proximo_z = 8
	
	# --- BLOCO 1: Gramas Escuras (Z = 8, 7, 6, 5) ---
	# Rodar 4 vezes faz o proximo_z ir de 8 até 5
	for i in range(4):
		spawnar_proxima_faixa_especifica(cena_grama_escura)
		
	# --- BLOCO 2: Gramas Normais de Recuo e Spawn (Z = 4, 3, 2, 1, 0) ---
	# Rodar 5 vezes faz o proximo_z construir no 4, 3, 2, 1 e no 0 (onde o player nasce)
	for i in range(5):
		spawnar_proxima_faixa_especifica(cena_grama)
		
	# --- BLOCO 3: Gramas Normais da Frente (Z = -1, -2, -3, -4, -5) ---
	# Como você pediu grama no -1, -3 e -5, para manter o grid contínuo sem buracos,
	# geramos as gramas normais do -1 até o -5 (Z = -1, -2, -3, -4, -5)
	# Rodar 5 vezes faz o proximo_z ir de -1 até -5
	for i in range(5):
		spawnar_proxima_faixa_especifica(cena_grama)
		
	# Neste ponto exato, o proximo_z virou -6 automaticamente!
	
	# 2. Preenche o resto da tela com o mapa infinito a partir de Z = -6, -7...
	for i in range(quantidade_faixas_na_tela):
		gerar_logica_procedural_faixa()
func _process(_delta: float) -> void:
	if player_nodo == null or player_nodo.is_dead:
		return
		
	# No Crossy Road o jogador anda para o Z negativo. 
	# Vamos converter a posição atual dele para um número positivo de "linhas andadas"
	var linha_atual_player = int(abs(player_nodo.global_position.z))
	
	# --- MECÂNICA 1: GERAÇÃO INFINITA E LIMPEZA ---
	# Se o jogador passou da metade das faixas visíveis, gera uma nova na frente e apaga a mais antiga atrás
	if linha_atual_player > (proximo_z_para_linha() - quantidade_faixas_na_tela):
		gerar_logica_procedural_faixa()
		
		# Se passou do limite de faixas na tela, limpa a que ficou muito lá atrás
		if faixas_vivas.size() > quantidade_faixas_na_tela + 10:
			var faixa_antiga = faixas_vivas.pop_front()
			if is_instance_valid(faixa_antiga):
				faixa_antiga.queue_free() # Some do mapa e libera memória!
				
	# --- MECÂNICA 2: SE TENTAR VOLTAR 5 PASSOS, MORRE ---
	# Atualiza o recorde se ele avançou mais do que nunca
	if linha_atual_player > maior_linha_alcancada:
		maior_linha_alcancada = linha_atual_player
		
	# Se a diferença entre o recorde dele e onde ele está agora for maior ou igual a 5, tchau!
	if (maior_linha_alcancada - linha_atual_player) >= limite_passos_atras:
		player_nodo.die("carro") # Usa a animação de ser esmagado/parado

# Define qual tipo de faixa vai vir com base na última (Sua lógica do Crossy Road)
func gerar_logica_procedural_faixa() -> void:
	var cena_escolhida: PackedScene = null
	var inverter_rua = false
	var sorteio_inversao = randf() > 0.5
	
	match ultimo_tipo:
		"grama":
			var escolha = randi() % 2
			if escolha == 0:
				cena_escolhida = cena_rio_invertido if sorteio_inversao else cena_rio
				ultimo_tipo = "rio"
			else:
				cena_escolhida = cena_rua
				inverter_rua = sorteio_inversao
				ultimo_tipo = "rua"
				
		"rio":
			var escolha = randi() % 3
			#if escolha == 0:
				#cena_escolhida = cena_rio_invertido if sorteio_inversao else cena_rio
				#ultimo_tipo = "rio"
			#elif escolha == 1:
				#cena_escolhida = cena_rio_picles
				#ultimo_tipo = "rio"
			if escolha == 0:
				cena_escolhida = cena_rua
				inverter_rua = sorteio_inversao
				ultimo_tipo = "picles"
			else:
				cena_escolhida = cena_grama
				ultimo_tipo = "grama"
				
		"rua":
			var escolha = randi() % 2
			if escolha == 0:
				cena_escolhida = cena_rua
				inverter_rua = sorteio_inversao
				ultimo_tipo = "rua"
			else:
				cena_escolhida = cena_grama
				ultimo_tipo = "grama"
		"picles":
			var escolha = randi() % 2
			if escolha == 0:
				cena_escolhida = cena_rio_picles
				ultimo_tipo = "rio"
			else:
				cena_escolhida = cena_grama
				ultimo_tipo = "grama"
		

	spawnar_faixa_na_posicao(cena_escolhida, inverter_rua)

# Instancia a faixa na memória e adiciona na lista de rastreio
func spawnar_faixa_na_posicao(cena: PackedScene, inverter: bool) -> void:
	if cena == null:
		return
		
	var nova_faixa = cena.instantiate() as Node3D
	add_child(nova_faixa)
	
	nova_faixa.global_position = Vector3(0.0, 0.0, float(proximo_z))
	
	if inverter:
		nova_faixa.global_rotation.y = deg_to_rad(180)
		
	faixas_vivas.append(nova_faixa) # Guarda a referência para poder apagar depois
	proximo_z -= 1 # Próxima faixa vai ser colocada mais para frente

# Helper para spawnar as gramas fixas do início do grid
func spawnar_proxima_faixa_especifica(cena: PackedScene) -> void:
	var nova_faixa = cena.instantiate() as Node3D
	add_child(nova_faixa)
	nova_faixa.global_position = Vector3(0.0, 0.0, float(proximo_z))
	faixas_vivas.append(nova_faixa)
	proximo_z -= 1

# Função auxiliar para ler o Z atual de forma positiva
func proximo_z_para_linha() -> int:
	return int(abs(proximo_z))

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
	
# Função que escreve a pontuação na tela ---
func atualizar_texto_score(nova_pontuacao: int) -> void:
	# Verificamos se o nó existe para evitar erros
	if score_label != null:
		# Transforma o número inteiro (int) em um texto (String) para colocar no Label
		score_label.text = str(nova_pontuacao)
