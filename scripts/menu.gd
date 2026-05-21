extends Node3D

# Função chamada quando o botão Jogar for pressionado
func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/jogo.tscn")
	# No futuro você colocará algo como: get_tree().change_scene_to_file("res://cenas/jogo.tscn")

# Função chamada quando o botão Tutorial for pressionado
func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/tutorial.tscn")
