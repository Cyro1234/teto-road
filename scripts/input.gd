extends CharacterBody3D

@export var move_speed := 10
@onready var altura_inicial_y: float = global_position.y

var rotation_speed = 2.0
var target_rotation_y := 0.0
var target_position: Vector3
var is_moving := false
var is_dead := false

# Variáveis para o sistema de Score
signal pontuacao_atualizada(nova_pontuacao) # Sinal que vai avisar a interface quando o score mudar
var z_inicial: float = 0.0                  # Guarda a posição de onde o player começa 
var pontuacao_maxima: int = 0               # Guarda o recorde de passos para frente

# VARIÁVEIS DE CONTROLE DA BAGUETE / PICLES
var baguete_atual: Node3D = null
var estava_na_baguete := false
var ultima_baguete_id: Node3D = null # Guarda a referência da baguete/picles mesmo durante o pulo

func _ready():
	# Garante que começamos alinhados no grid
	global_position.x = round(global_position.x)
	global_position.z = round(global_position.z)
	target_position = global_position
	# Salva a posição Z de início
	z_inicial = global_position.z

func _physics_process(delta):
	if is_dead: return
	
	rotation.y = lerp_angle(rotation.y, target_rotation_y, 10 * delta)
	
	# 1. Atualiza se o sensor encontrou a baguete ou picles embaixo
	checar_se_esta_na_baguete()
	
	# --- USAR A ULTIMA BAGUETE/PICLES SE ESTIVER PULANDO ---
	var baguete_para_mover = baguete_atual if baguete_atual != null else (ultima_baguete_id if is_moving else null)
	
	if baguete_para_mover != null and is_instance_valid(baguete_para_mover):
		estava_na_baguete = true
		if baguete_atual != null:
			ultima_baguete_id = baguete_atual
		
		# Buscando o método get_velocidade() subindo na hierarquia se necessário
		var objeto_com_velocidade = baguete_para_mover
		if not objeto_com_velocidade.has_method("get_velocidade") and objeto_com_velocidade.get_parent():
			objeto_com_velocidade = objeto_com_velocidade.get_parent()
			
		if objeto_com_velocidade.has_method("get_velocidade"):
			var velocidade = objeto_com_velocidade.get_velocidade()
			
			var movimento = velocidade * delta
			
			# Adiciona o movimento horizontal ao destino
			target_position.x += movimento.x
			# TRAVA: Impede o target_position de passar de -4 ou 4 no eixo X
			target_position.x = clamp(target_position.x, -4.0, 4.0)
			
			if not is_moving:
				global_position = target_position
	else:
		# Se ela saiu da baguete sozinha sem pular
		if estava_na_baguete and not is_moving:
			alinhar_no_grid()

	# Movimenta o suave de pulo até o destino
	if is_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		if global_position.distance_to(target_position) < 0.01:
			global_position = target_position
			is_moving = false
			checar_pontuacao()
			
			# Se ela acabou de aterrissar no chão firme (grama/rua) vinda de uma baguete/picles, crava no grid!
			if estava_na_baguete and baguete_atual == null:
				alinhar_no_grid()
	else:
		handle_input()

func handle_input():
	var direction = Vector3.ZERO
	
	if Input.is_action_just_pressed("cima"):
		direction.z -= 1
	elif Input.is_action_just_pressed("baixo"):
		if target_position.z >= 4:
			direction.x = 0
		else:
			direction.z += 1
	elif Input.is_action_just_pressed("esquerda"):
		if target_position.x <= -4:
			direction.x = 0
		elif baguete_atual != null: # Impede mover para os lados se estiver na baguete/picles
			direction.x = 0
		else:
			direction.x -= 1
	elif Input.is_action_just_pressed("direita"):
		if target_position.x >= 4:
			direction.x = 0
		elif baguete_atual != null: # Impede mover para os lados se estiver na baguete/picles
			direction.x = 0
		else:
			direction.x += 1
			
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

# --- FUNÇÃO CORRIGIDA PARA IDENTIFICAR PICLES TAMBÉM ---
func checar_se_esta_na_baguete():
	var space_state = get_world_3d().direct_space_state
	var origen = global_position + Vector3(0, 0.5, 0)
	var destino = global_position + Vector3(0, -2.5, 0)
	var query = PhysicsRayQueryParameters3D.create(origen, destino)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = [get_rid()]
	
	var resultado = space_state.intersect_ray(query)
	
	if resultado and resultado.collider:
		var colisor = resultado.collider
		
		# Verifica se o colisor ou algum pai dele pertence ao grupo baguete OU picles
		var e_baguete = false
		var atual = colisor
		while atual != null:
			if atual.is_in_group("baguete") or atual.is_in_group("picles"):
				e_baguete = true
				break
			atual = atual.get_parent()
			
		if e_baguete:
			# Procura qualquer nó na hierarquia que tenha a função get_velocidade()
			atual = colisor
			while atual != null:
				if atual.has_method("get_velocidade"):
					baguete_atual = atual
					return atual
				atual = atual.get_parent()
				
			# Caso encontre o grupo mas não ache a função, guarda como fallback
			atual = colisor
			while atual != null:
				if atual.is_in_group("baguete") or atual.is_in_group("picles"):
					baguete_atual = atual
					return atual
				atual = atual.get_parent()

	baguete_atual = null

func die(tipo_de_morte: String = "carro"):
	velocity = Vector3.ZERO
	is_dead = true
	var tween = create_tween()
	if tipo_de_morte == "agua":
		tween.tween_property(self, "global_position:y", global_position.y - 1.2, 0.4)
		tween.parallel().tween_property(self, "scale", Vector3(0.2, 0.2, 0.2), 0.4)
	else:
		$".".scale.y = 0.2

func checar_pontuacao():
	var passos_dados = int(z_inicial - global_position.z)
	if passos_dados > pontuacao_maxima:
		pontuacao_maxima = passos_dados
		pontuacao_atualizada.emit(pontuacao_maxima)
