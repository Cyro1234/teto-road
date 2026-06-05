extends Camera3D

@export var target: Node3D
@export var z_offset := 6.0
@export var x_offset := 1.0

func _process(delta):
	# Só segue o alvo se ele existir na cena
	if target:
		# Deixa o movimento suave.
		global_position.z = lerp(global_position.z, target.global_position.z + z_offset, 5 * delta)
		global_position.x = lerp(global_position.x, target.global_position.x + x_offset, 5 * delta)

# Se apertar o botão de recomeçar
func _on_button_pressed():
	get_tree().reload_current_scene()
