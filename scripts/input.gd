extends CharacterBody3D

@export var move_speed := 10
var rotation_speed = 2.0
var target_rotation_y := 0.0

var target_position: Vector3
var is_moving := false
var is_dead := false

# VARIÁVEIS PARA A BAGUETE
var baguete_atual: Node3D = null
var estava_na_baguete := false

func _ready():
	target_position = global_position

func _process(delta):
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, target_rotation_y, 10 * delta)
	
	checar_se_esta_na_baguete()
	
	# ... (código anterior do _process)
	
	if baguete_atual != null:
		estava_na_baguete = true
		if baguete_atual.has_method("get_velocidade"):
			var movimento_da_baguete = baguete_atual.get_velocidade() * delta
			global_position += movimento_da_baguete
			target_position += movimento_da_baguete
	else:
		if estava_na_baguete and not is_moving:
			# Alinha perfeitamente no Grid de números inteiros horizontais
			global_position.x = round(global_position.x)
			global_position.z = round(global_position.z)
			# Força a altura a voltar para o nível zero (ajuste para a altura inicial do seu player se for diferente)
			global_position.y = 0.0 
			
			target_position = global_position
			estava_na_baguete = false
	
	if is_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		if global_position.distance_to(target_position) < 0.01:
			global_position = target_position
			is_moving = false
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
		else:
			direction.x -= 1
	elif Input.is_action_just_pressed("direita"):
		if target_position.x >= 4:
			direction.x = 0
		else:
			direction.x += 1
		
	if direction != Vector3.ZERO:
		if estava_na_baguete:
			target_position.x = round(target_position.x)
			target_position.z = round(target_position.z)
			global_position = target_position
			estava_na_baguete = false

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

func checar_se_esta_na_baguete():
	var space_state = get_world_3d().direct_space_state
	# Aumentamos o alcance para baixo (de -1.5 para -2.5) para garantir que pega a baguete no rio
	var origem = global_position + Vector3(0, 0.5, 0)
	var destino = global_position + Vector3(0, -2.5, 0)
	var query = PhysicsRayQueryParameters3D.create(origem, destino)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var resultado = space_state.intersect_ray(query)
	
	if resultado and resultado.collider:
		var colisor = resultado.collider
		if colisor.is_in_group("baguete") or (colisor.get_parent() and colisor.get_parent().is_in_group("baguete")):
			if colisor.is_in_group("baguete"):
				baguete_atual = colisor
			else:
				baguete_atual = colisor.get_parent()
			return
			
	baguete_atual = null
	
# MODIFICADO: Agora aceita um tipo de morte ("agua" ou "carro")
func die(tipo_de_morte: String = "carro"):
	velocity = Vector3.ZERO
	is_dead = true
	
	var tween = create_tween()
	
	if tipo_de_morte == "agua":
		# Animação de Afogar
		tween.tween_property(self, "global_position:y", global_position.y - 1.2, 0.4)
		tween.parallel().tween_property(self, "scale", Vector3(0.2, 0.2, 0.2), 0.4)
	else:
		# Animação de Esmagar (Padrão do Carro)
		$".".scale.y = 0.2
