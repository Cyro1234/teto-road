extends Control

@onready var botao_recomecar: Button = $VBoxContainer/BotaoRecomecar
@onready var botao_menu: Button = $VBoxContainer/BotaoMenu
@onready var vbox: VBoxContainer = $VBoxContainer

var aviso_label: Label = null

# VARIÁVEL DE CONTROLE: Salva se o botão deve carregar o jogo principal ou apenas reiniciar
var transitar_para_jogo := false

func _ready() -> void:
	hide() # Garante que o menu começa escondido
	
	# REGISTRO EM GRUPO: Permite que qualquer script do jogo encontre o menu instantaneamente
	add_to_group("menu_pausa")
	
	process_mode = Node.PROCESS_MODE_ALWAYS 
	botao_recomecar.pressed.connect(_on_recomecar_pressed)
	botao_menu.pressed.connect(_on_voltar_menu_pressed)

func _input(event: InputEvent) -> void:
	# Impede o pause manual via ESC caso o jogador já tenha morrido
	var player = get_tree().get_first_node_in_group("player")
	if player and player.is_dead:
		return

	if event.is_action_pressed("ui_cancel"):
		if visible:
			despausar_jogo()
		else:
			pausar_jogo()

func pausar_jogo() -> void:
	# Se for um pause normal por ESC, limpa avisos e reseta as variáveis
	botao_recomecar.text = "Reiniciar"
	transitar_para_jogo = false
	
	if aviso_label and is_instance_valid(aviso_label):
		aviso_label.queue_free()
		aviso_label = null
		
	show()
	get_tree().paused = true

func despausar_jogo() -> void:
	hide()
	get_tree().paused = false

# --- CONFIGURA A TELA DE GAME OVER / FIM DE JOGO ---
func exibir_game_over(texto_botao: String = "Reiniciar", texto_aviso: String = "") -> void:
	botao_recomecar.text = texto_botao
	
	# --- CORREÇÃO: Ativa a transição para o jogo se o texto do botão for "Jogar" ---
	transitar_para_jogo = (texto_botao == "Jogar")
	
	# Limpa avisos antigos se houver
	if aviso_label and is_instance_valid(aviso_label):
		aviso_label.queue_free()
		aviso_label = null
		
	# Se um aviso foi enviado, cria um Label de texto dinamicamente na hora
	if texto_aviso != "":
		aviso_label = Label.new()
		aviso_label.text = texto_aviso
		aviso_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(aviso_label)
		vbox.move_child(aviso_label, 0) # Move para o topo do menu
		
	show()
	get_tree().paused = true # Pausa o jogo

func _on_recomecar_pressed() -> void:
	get_tree().paused = false # Despausa o motor do jogo
	
	# --- CORREÇÃO: Decide para onde enviar o jogador ao clicar ---
	if transitar_para_jogo:
		get_tree().change_scene_to_file("res://cenas/jogo.tscn") # Vai direto para a ação!
	else:
		get_tree().reload_current_scene() # Reinicia a fase atual normalmente

func _on_voltar_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/menu.tscn")
