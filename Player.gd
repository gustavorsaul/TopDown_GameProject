extends CharacterBody2D

@export var speed = 300.0

@onready var sprite = $AnimatedSprite2D

@export var arrow : PackedScene

@onready var tiros = 0

@export var dash_distance = 100.0
@export var dash_speed = 1000.0
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_start_position = Vector2.ZERO

func get_8way_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	# Verificar se shift foi pressionado para dash
	if Input.is_action_just_pressed("shift") and input_direction != Vector2.ZERO:
		start_dash(input_direction)
	
	# Se não estiver fazendo dash, movimento normal
	if not is_dashing:
		velocity = input_direction * speed
	
func animate():
	
	if velocity.x > 0:
		sprite.play("right")
	elif velocity.x < 0:
		sprite.play("left")
	elif velocity.y > 0:
		sprite.play("down")
	elif velocity.y < 0:
		sprite.play("up")
	else:
		sprite.stop()
		
func start_dash(direction: Vector2):
	if not is_dashing:
		is_dashing = true
		dash_direction = direction
		dash_start_position = position
		velocity = dash_direction * dash_speed
		print("Dash!")

func update_dash(delta):
	if is_dashing:
		# Usar velocity para respeitar colisões
		velocity = dash_direction * dash_speed
		
		# Verificar se já percorreu a distância do dash
		if position.distance_to(dash_start_position) >= dash_distance:
			is_dashing = false
			velocity = Vector2.ZERO

func move_8way(delta):
	get_8way_input()
	update_dash(delta)
	animate()
	
	# Mover e verificar colisões
	move_and_slide()
	
	# Se estiver fazendo dash e colidiu, parar o dash
	if is_dashing and is_on_wall():
		is_dashing = false
		velocity = Vector2.ZERO

func _physics_process(delta):
	move_8way(delta)
	
	if (Input.is_action_just_pressed("mouseLeft")):
		tiros += 1
		print("Tiro ", tiros)
		var b := arrow.instantiate()
		b.position = position
		b.target = get_global_mouse_position()
		owner.add_child(b)
			
