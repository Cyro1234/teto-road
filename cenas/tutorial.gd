extends Node3D

# Carrega as cenas dos módulos (ajuste os caminhos se suas pastas forem diferentes)
@export var cena_grama: PackedScene = preload("res://cenas/partes/grama.tscn")
@export var cena_grama_escura: PackedScene = preload("res://cenas/partes/grama_escura.tscn")
@export var cena_rio: PackedScene = preload("res://cenas/partes/rio.tscn")
@export var cena_rua: PackedScene = preload("res://cenas/partes/rua.tscn")

func _ready() -> void:
	gerar_mapa_tutorial()

func gerar_mapa_tutorial() -> void:
	# 1. Definição das posições para cada tipo de terreno
	var posicoes_grama = [-5, -3, -1, 0, 1, 2, 3, 4]
	var posicoes_grama_escura = [5, 6, 7, 8]
	var posicoes_rio = [-4]
	var posicoes_rua = [-2]
	
	# Spawna as gramas normais
	for z in posicoes_grama:
		spawnar_faixa(cena_grama, z)
		
	# Spawna as gramas escuras
	for z in posicoes_grama_escura:
		spawnar_faixa(cena_grama_escura, z)
		
	# Spawna os rios
	for z in posicoes_rio:
		spawnar_faixa(cena_rio, z)
		
	# Spawna as ruas
	for z in posicoes_rua:
		spawnar_faixa(cena_rua, z)

func spawnar_faixa(cena: PackedScene, posicao_z: float) -> void:
	if cena == null:
		print("Erro: Uma das cenas de faixa não foi carregada no script do tutorial!")
		return
		
	# Instancia o bloco/faixa na memória
	var nova_faixa = cena.instantiate() as Node3D
	
	# Adiciona como filho da cena do tutorial
	add_child(nova_faixa)
	
	# Define a posição baseada no grid. 
	# Mantemos X e Y em 0 e mudamos o Z para alinhar as linhas do Crossy Road
	nova_faixa.global_position = Vector3(0.0, 0.0, posicao_z)
