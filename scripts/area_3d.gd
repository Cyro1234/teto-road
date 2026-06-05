extends Area3D

# O _ready liga o sinal de colisão direto no código
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Checa se quem bateu foi o player pra esmagar ele.
	if body.is_in_group("player"):
		body.die("carro")
