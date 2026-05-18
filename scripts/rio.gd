extends Area3D

var player_no_rio : CharacterBody3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_no_rio = body

func _on_body_exited(body: Node3D) -> void:
	if body == player_no_rio:
		player_no_rio = null

func _process(_delta: float) -> void:
	if player_no_rio and not player_no_rio.is_dead:
		if not player_no_rio.is_moving:
			if not esta_na_baguete(player_no_rio):
				# PASSA O PARAMETRO "agua" PRO PLAYER AFUNDAR
				player_no_rio.die("agua")

func esta_na_baguete(player: CharacterBody3D) -> bool:
	# Vamos pedir para o próprio Rio ver os corpos físicos que estão sobrepostos dentro dele
	var corpos_no_rio = get_overlapping_bodies()
	var areas_no_rio = get_overlapping_areas()
	
	var tudo_no_rio = []
	tudo_no_rio.append_array(corpos_no_rio)
	tudo_no_rio.append_array(areas_no_rio)
	
	for objeto in tudo_no_rio:
		# Verifica se o objeto ou o pai dele pertence ao grupo baguete
		if objeto.is_in_group("baguete") or (objeto.get_parent() and objeto.get_parent().is_in_group("baguete")):
			# Calcula a distância horizontal entre a Teto e a Baguete
			var dist_player = Vector2(player.global_position.x, player.global_position.z)
			var dist_baguete = Vector2(objeto.global_position.x, objeto.global_position.z)
			var distancia = dist_player.distance_to(dist_baguete)
			
			# Se estiver no mesmo espaço horizontal do bloco da baguete, ela está salva!
			if distancia < 1.8:
				return true
				
	return false
