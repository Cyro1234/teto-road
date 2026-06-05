extends Node3D

# Só troca de cena quando clica nos botões (Sinais do painel de nó UI)
func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://cenas/jogo.tscn")

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://cenas/tutorial.tscn")
