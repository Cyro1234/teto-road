extends CharacterBody3D

@export var move_speed := 10

var target_position: Vector3
var is_moving := false

func _ready():
	target_position = global_position

func _process(delta):
	if is_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		if global_position.distance_to(target_position) < 0.01:
			global_position = target_position
			is_moving = false
	else:
		handle_input()

func handle_input():
	var direction = Vector3.ZERO
	
	if Input.is_action_just_pressed("cima"):
		direction.z -= 1
		#print(direction)
		#print(target_position)
	elif Input.is_action_just_pressed("baixo"):
		direction.z += 1
		#print(direction)
		#print(target_position)
	elif Input.is_action_just_pressed("esquerda"):
		if target_position.x <= -4:
			direction.x == 0
		else:
			direction.x -= 1
		#print(direction)
		#print(target_position)
	elif Input.is_action_just_pressed("direita"):
		if target_position.x >= 4:
			direction.x == 0
		else:
			direction.x += 1
		#print(direction)
		#print(target_position)

	if direction != Vector3.ZERO:
		target_position += direction
		is_moving = true
