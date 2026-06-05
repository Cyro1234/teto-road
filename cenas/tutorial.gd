extends Node3D

# Carrega as cenas dos módulos de novo
@export var cena_grama: PackedScene = preload("res://cenas/partes/grama.tscn")
@export var cena_grama_escura: PackedScene = preload("res://cenas/partes/grama_escura.tscn")
@export var cena_rio: PackedScene = preload("res://cenas/partes/rio.tscn")
@export var cena_rio_invertido: PackedScene = preload("res://cenas/partes/rio_invertido.tscn")
@export var cena_rua: PackedScene = preload("res://cenas/partes/rua.tscn")
@export var cena_picles: PackedScene = preload("res://cenas/partes/rio_picles.tscn")

@onready var painel_dialogo: PanelContainer = $CanvasLayer/PainelDialogo
@onready var texto_dialogo: Label = $CanvasLayer/PainelDialogo/MarginContainer/TextoDialogo
@onready var player: CharacterBody3D = $Player

# VARIÁVEIS ADICIONADAS PARA O CONTROLE DE MORTE E TRAVA
var morte_recuo_habilitada := false
var maior_linha_alcancada := 0

# Dicionário (chave/valor) para guardar as mensagens que já foram exibidas
var dialogos_vistos := {
	"inicio": false,
	"rio": false,
	"rua": false,
	"picles": false,
	"fim": false
}

func _ready() -> void:
	gerar_mapa_tutorial()
	
	# Conecta os sinais das áreas de gatilho dinamicamente pelo script
	$GatilhoRio.body_entered.connect(_on_gatilho_rio_entered)
	$GatilhoRua.body_entered.connect(_on_gatilho_rua_entered)
	$GatilhoPicles.body_entered.connect(_on_gatilho_picles_entered)
	$GatilhoFim.body_entered.connect(_on_gatilho_fim_entered)
	
	await get_tree().process_frame
	mostrar_mensagem("inicio", "Bem-vindo ao Tutorial! Use as teclas WASD/⭡⭠⭣⭢ para se movimentar e avançar.")

func _process(_delta: float) -> void:
	if player == null or player.is_dead:
		return
		
	# IMPEDIR O JOGADOR DE AVANAR ALÉM DE Z = -13 (o limite do mapa tutorial)
	if player.target_position.z < -13:
		player.target_position.z = -13
		
	# SE VOLTAR 4 POSIÇÕES APÓS O FIM, MORRE 
	if morte_recuo_habilitada:
		var linha_atual_player = int(abs(player.global_position.z))
		
		if linha_atual_player > maior_linha_alcancada:
			maior_linha_alcancada = linha_atual_player
			
		if (maior_linha_alcancada - linha_atual_player) >= 4:
			player.die("carro", true)

func _input(event: InputEvent) -> void:
	# Se o painel estiver visível e o jogador apertar para avançar
	if painel_dialogo.visible and (event.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		fechar_mensagem()

func gerar_mapa_tutorial() -> void:
	# Array das posições exatas pra eu construir manualmente
	var posicoes_grama = [-13 ,-12,-11,-10,-9, -5, -3, -1, 0, 1, 2, 3, 4]
	var posicoes_grama_escura = [-20,-19,-18,-17,-16,-15,-14,5, 6, 7, 8]
	var posicoes_rio = [-8, -4]
	var posicoes_rua = [-2]
	var posicoes_picles = [-7]
	var posicoes_rio_invertido = [-6]

	# Iterando nos Arrays pra spawnar a pista na coordenada certa
	for z in posicoes_grama: spawnar_faixa(cena_grama, z)
	for z in posicoes_grama_escura: spawnar_faixa(cena_grama_escura, z)
	for z in posicoes_rio: spawnar_faixa(cena_rio, z)
	for z in posicoes_rua: spawnar_faixa(cena_rua, z)
	for z in posicoes_picles: spawnar_faixa(cena_picles, z)
	for z in posicoes_rio_invertido: spawnar_faixa(cena_rio_invertido, z)

func spawnar_faixa(cena: PackedScene, posicao_z: float) -> void:
	if cena == null: return
	var nova_faixa = cena.instantiate() as Node3D
	add_child(nova_faixa)
	nova_faixa.global_position = Vector3(0.0, 0.0, posicao_z)

# Funções de controle do Diálogo
func mostrar_mensagem(chave: String, texto: String) -> void:
	if dialogos_vistos[chave]:
		return
		
	dialogos_vistos[chave] = true
	texto_dialogo.text = texto
	painel_dialogo.show()
	
	# Trava o jogador impedindo que ele continue andando enquanto lê
	if player:
		player.set_physics_process(false)
		player.is_moving = false

func fechar_mensagem() -> void:
	painel_dialogo.hide()
	# Devolve o controle de movimentos para o jogador
	if player:
		player.set_physics_process(true)

# Sinais dos Gatilhos
func _on_gatilho_rio_entered(body: Node) -> void:
	if body.is_in_group("player"):
		mostrar_mensagem("rio", "Cuidado! À frente está o Rio. Você precisa pular em cima das Baguetes para atravessar em segurança!")

func _on_gatilho_rua_entered(body: Node) -> void:
	if body.is_in_group("player"):
		mostrar_mensagem("rua", "Atenção! Esta é a Rua. Espere os carros passarem e pegue o tempo certo para não ser atropelado.")

func _on_gatilho_picles_entered(body: Node) -> void:
	if body.is_in_group("player"):
		mostrar_mensagem("picles", "Picles podem aparecer no rio para te auxiliar a passar das baguetes!")

func _on_gatilho_fim_entered(body: Node) -> void:
	if body.is_in_group("player"):
		mostrar_mensagem("fim", "Parabéns, esse é o final do tutorial, volte para trás para iniciar o jogo!")
		# Habilita a morte por recuo e salva a marca inicial baseada na posição do gatilho
		morte_recuo_habilitada = true
		maior_linha_alcancada = int(abs(player.global_position.z))
