extends Camera3D

@export var target: Node3D
@export var z_offset := 6.0
@export var x_offset := 1

func _process(delta):
	if target:
		var pos = global_position
		
		pos.z = lerp(pos.z, target.global_position.z + z_offset, 5 * delta)
		pos.x = lerp(pos.x, target.global_position.x + x_offset, 5 * delta)
		global_position = pos


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
