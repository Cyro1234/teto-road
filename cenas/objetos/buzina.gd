extends AudioStreamPlayer3D

@onready var buzina: AudioStreamPlayer3D = $"."

var tocou = false
var rng
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng = RandomNumberGenerator.new().randi() % 20 # gera um numero aleatorio a primeira vez

func _process(_delta: float) -> void:
	
	var parent_node = get_parent()
	
	# Example: Print the parent's name
	if parent_node:
		var parent_node_node = parent_node.get_parent()
		if "progress" in parent_node_node:
			#print(parent_node.get_parent().progress)
			
			if parent_node_node.progress >= 9.0 and parent_node_node.progress <= 9.9 and tocou == false:		
				#print(rng)
				if rng == 0:
					buzina.play()
					tocou = true
					
			if parent_node_node.progress_ratio >= 0.99 and tocou == true:
				tocou = false
			if parent_node_node.progress_ratio >= 0.99:
				rng = RandomNumberGenerator.new().randi() % 20 # reseta o rng sempre q terminar o progresso
