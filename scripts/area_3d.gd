extends Area3D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Chama especificando que foi o carro (vai esmagar)
		body.die("carro")
		print("atropelado")
