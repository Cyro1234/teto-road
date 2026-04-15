extends Area3D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		#body.queue_free()
		body.die()
		print("foi")
