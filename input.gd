extends CharacterBody3D

@export var move_speed := 10
var rotation_speed = 2.0
var target_rotation_y := 0.0

var target_position: Vector3
var is_moving := false

var is_dead := false

func _ready():
	target_position = global_position

func _process(delta):
	if is_dead:
		return
	rotation.y = lerp_angle(rotation.y, target_rotation_y, 10 * delta)
	
	if is_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
		
		
		if global_position.distance_to(target_position) < 0.01:
			global_position = target_position
			is_moving = false
	else:
		handle_input()

func handle_input():
	#var isCima := false
	#var isBaixo := false
	#var isEsquerda := false
	#var isDireita := false
	
	var direction = Vector3.ZERO
	
	
	if Input.is_action_just_pressed("cima"):
		direction.z -= 1
		#Vector3(0, -90, 0)
		print(rotation)
		
		#print(direction)
		#print(target_position)
	elif Input.is_action_just_pressed("baixo"):
		if target_position.z >=4:
			direction.x = 0
		else:
			direction.z += 1
		#Vector3(0, -180, 0)
		print(rotation)
		#print(direction)
		#print(target_position)
	elif Input.is_action_just_pressed("esquerda"):
		if target_position.x <= -4:
			direction.x = 0
		else:
			direction.x -= 1
		#Vector3(0, -90, 0)
		print(rotation)
		#print(direction)
		#print(target_position)
	elif Input.is_action_just_pressed("direita"):
		if target_position.x >= 4:
			direction.x = 0
		else:
			direction.x += 1
		#Vector3(0, -90, 0)
		#rotate_y()
		print(rotation)
		#print(direction)
		#print(target_position)
		
	if direction != Vector3.ZERO:
		target_position += direction
		is_moving = true
		
		if direction.x > 0:
			target_rotation_y = deg_to_rad(-90)
		elif direction.x < 0:
			target_rotation_y = deg_to_rad(90)
		elif direction.z > 0:
			target_rotation_y = deg_to_rad(180)
		elif direction.z < 0:
			target_rotation_y = deg_to_rad(0)


func die():
	velocity = Vector3.ZERO
	is_dead = true
	
	$".".scale.y = 0.2
