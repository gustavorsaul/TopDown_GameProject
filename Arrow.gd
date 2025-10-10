extends Area2D

@export var speed = 500.0
@export var max_distance = 2000.0  # Distância máxima que a flecha pode viajar
var direction: Vector2
var start_position: Vector2

func _ready() -> void:
	$AnimatedSprite2D.play()
	# Conectar sinais de colisão
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func setup_arrow(target_pos: Vector2) -> void:
	# Define a direção baseada na posição inicial e alvo
	direction = position.direction_to(target_pos)
	start_position = position
	# Rotaciona a flecha para apontar na direção correta
	rotation = direction.angle()
	
func _physics_process(delta: float) -> void:
	# Move a flecha na direção definida
	position += direction * speed * delta
	
	# Verifica se já viajou a distância máxima
	if position.distance_to(start_position) >= max_distance:
		queue_free()
		
	
func animation_finished():
	print("Acabou a animação")
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Verifica se o corpo é um inimigo que pode receber dano
	# E não é o player (para evitar colisão entre arrow e player)
	if body.has_method("take_damage") and not body.is_in_group("player"):
		body.take_damage(1)
		queue_free()
	# Se colidir com qualquer outro corpo (paredes, obstáculos), também para
	elif not body.is_in_group("player"):
		queue_free()
