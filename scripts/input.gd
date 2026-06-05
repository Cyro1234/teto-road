extends CharacterBody3D

@export var move_speed := 10
@onready var altura_inicial_y: float = global_position.y
@onready var animacao: AnimationPlayer = $AnimationPlayer
@onready var esmaga: AudioStreamPlayer3D = $esmaga
@onready var pulo: AudioStreamPlayer3D = $pulo
@onready var agua_morte: AudioStreamPlayer3D = $agua_morte

var rotation_speed = 2.0
var target_rotation_y := 0.0
var target_position: Vector3
var is_moving := false
var is_dead := false

# Variáveis para o sistema de Score
signal pontuacao_atualizada(nova_pontuacao)
var z_inicial: float = 0.0                  
var pontuacao_maxima: int = 0               

# VARIÁVEIS DE CONTROLE DA BAGUETE / PICLES
var baguete_atual: Node3D = null
var estava_na_baguete := false
var ultima_baguete_id: Node3D = null 

func _ready():
	global_position.x = round(global_position.x)
	global_position.z = round(global_position.z)
	target_position = global_position
	z_inicial = global_position.z

func _physics_process(delta):
	if is_dead: return
	
	rotation.y = lerp_angle(rotation.y, target_rotation_y, 10 * delta)
	
	checar_se_esta_na_baguete()
	
	var baguete_para_mover = baguete_atual if baguete_atual != null else (ultima_baguete_id if is_moving else null)
	
	if baguete_para_mover != null and is_instance_valid(baguete_para_mover):
		estava_na_baguete = true
		if baguete_atual != null:
			ultima_baguete_id = baguete_atual
			
		
		var objeto_com_velocidade = baguete_para_mover
		if not objeto_com_velocidade.has_method("get_velocidade") and objeto_com_velocidade.get_parent():
			objeto_com_velocidade = objeto_com_velocidade.get_parent()
			
		if objeto_com_velocidade.has_method("get_velocidade"):
			var velocidade = objeto_com_velocidade.get_velocidade()
			var movimento = velocidade * delta
			
			target_position.x += movimento.x
			target_position.x = clamp(target_position.x, -4.0, 4.0)
			
			if not is_moving:
				global_position = target_position
	else:
		if estava_na_baguete and not is_moving:
			alinhar_no_grid()

	if is_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		if global_position.distance_to(target_position) < 0.01:
			global_position = target_position
			is_moving = false
			checar_se_esta_na_baguete() # Atualiza o estado imediatamente ao pousar
			checar_pontuacao()
			
			if estava_na_baguete and baguete_atual == null:
				alinhar_no_grid()
			elif baguete_atual != null:
				# --- VERIFICA SE O NÓ OU SEUS FILHOS SÃO DO GRUPO PICLES ---
				var nodo_picles: Node3D = null
				if baguete_atual.is_in_group("picles"):
					nodo_picles = baguete_atual
				else:
					for child in baguete_atual.get_children():
						if child.is_in_group("picles"):
							nodo_picles = child
							break
				
				# Se encontrou o picles, centraliza perfeitamente nele
				if nodo_picles != null:
					global_position.x = nodo_picles.global_position.x
					target_position.x = nodo_picles.global_position.x
	else:
		handle_input()

func handle_input():
	var direction = Vector3.ZERO
	
	if Input.is_action_just_pressed("cima"):
		direction.z -= 1
		animacao.play("pulo")
		pulo.play()
	elif Input.is_action_just_pressed("baixo"):
		if target_position.z >= 4:
			direction.x = 0
			animacao.play("pulo")
			pulo.play()
		else:
			direction.z += 1
			animacao.play("pulo")
			pulo.play()
	elif Input.is_action_just_pressed("esquerda"):
		if target_position.x <= -4:
			direction.x = 0
			animacao.play("pulo")
			pulo.play()
		elif baguete_atual != null: 
			direction.x = 0
			animacao.play("pulo")
			pulo.play()
		else:
			direction.x -= 1
			animacao.play("pulo")
			pulo.play()
	elif Input.is_action_just_pressed("direita"):
		if target_position.x >= 4:
			direction.x = 0
			animacao.play("pulo")
			pulo.play()
		elif baguete_atual != null: 
			direction.x = 0
			animacao.play("pulo")
			pulo.play()
		else:
			direction.x += 1
			animacao.play("pulo")
			pulo.play()
			
	if direction != Vector3.ZERO:
		if estava_na_baguete:
			global_position.z = round(global_position.z)
			target_position = global_position
			
		target_position += direction
		is_moving = true
		
		if direction.x > 0:
			target_rotation_y = deg_to_rad(-90)
		elif direction.x < 0:
			target_rotation_y = deg_to_rad(90)
		elif direction.z > 0:
			target_rotation_y = deg_to_rad(180)
		elif direction.z < 0:
			target_rotation_y = deg_to_rad(0)

func alinhar_no_grid():
	global_position.x = round(global_position.x)
	global_position.z = round(global_position.z)
	
	if abs(global_position.y - altura_inicial_y) > 0.01:
		var tween = create_tween()
		tween.tween_property(self, "global_position:y", altura_inicial_y, 0.15).set_trans(Tween.TRANS_SINE)
	else:
		global_position.y = altura_inicial_y
		
	target_position = global_position
	target_position.y = altura_inicial_y
	estava_na_baguete = false
	ultima_baguete_id = null

# --- NOVA LOGICA BASEADA NA MESMA TOLERÂNCIA DE DISTÂNCIA DO RIO ---
func checar_se_esta_na_baguete():
	var melhor_objeto: Node3D = null
	var menor_distancia := 1.0 # Tolerância de 1.0 unidade (igual ao rio.gd)
	
	var candidatos = []
	candidatos.append_array(get_tree().get_nodes_in_group("baguete"))
	candidatos.append_array(get_tree().get_nodes_in_group("picles"))
	
	for objeto in candidatos:
		if not is_instance_valid(objeto): continue
		
		# Verifica se o objeto está na mesma fileira Z (arredondada) que o player
		if round(objeto.global_position.z) == round(global_position.z):
			# Mede a distância apenas no eixo X
			var dist_x = abs(global_position.x - objeto.global_position.x)
			if dist_x <= menor_distancia:
				menor_distancia = dist_x
				melhor_objeto = objeto

	if melhor_objeto != null:
		# Sobe a hierarquia para encontrar o nó com o script de velocidade (PathFollow3D)
		var atual = melhor_objeto
		while atual != null:
			if atual.has_method("get_velocidade"):
				baguete_atual = atual
				return
			atual = atual.get_parent()
		
		baguete_atual = melhor_objeto
	else:
		baguete_atual = null

# Altere a sua função die() antiga por esta versão atualizada:
func die(tipo_de_morte: String = "carro", por_recuo_tutorial: bool = false):
	velocity = Vector3.ZERO
	is_dead = true
	var tween = create_tween()
	if tipo_de_morte == "agua":
		tween.tween_property(self, "global_position:y", global_position.y - 1.2, 0.4)
		tween.parallel().tween_property(self, "scale", Vector3(0.2, 0.2, 0.2), 0.4)
		agua_morte.play()
	else:
		$".".scale.y = 0.2
		esmaga.play()
		
		
	# --- SISTEMA DE CORREÇÃO AUTOMÁTICA DE MENU ---
	# Espera meio segundo (tempo da animação de morte) antes de congelar a tela
	await get_tree().create_timer(1.5).timeout
	
	var menu = get_tree().get_first_node_in_group("menu_pausa")
	if menu:
		if por_recuo_tutorial:
			# Ativa o menu com os parâmetros especiais que você pediu
			menu.exibir_game_over("Jogar", "Não pode voltar tiles se não o jogo acaba")
		else:
			# Caso contrário, exibe o menu de derrota padrão do jogo
			menu.exibir_game_over("Reiniciar", "")

func checar_pontuacao():
	var passos_dados = int(z_inicial - global_position.z)
	if passos_dados > pontuacao_maxima:
		pontuacao_maxima = passos_dados
		pontuacao_atualizada.emit(pontuacao_maxima)
