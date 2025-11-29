extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO
var lifetime: float = 5.0  # Tempo de vida da flecha em segundos
var archer_parent = null  # Referência ao arqueiro que disparou esta flecha

func _ready() -> void:
	# Adiciona ao grupo "arrow" para facilitar detecção
	add_to_group("arrow")
	
	$AnimatedSprite2D.play()
	
	# Conectar sinal de colisão
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Configurar timer para destruir a flecha após um tempo
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = lifetime
	timer.timeout.connect(Callable(self, "queue_free"))
	add_child(timer)
	timer.start()
	
	# print("Flecha criada!")

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()  
	# print("Direção da flecha configurada: ", direction)

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	# print("Flecha colidiu com: ", body.name)
	
	# Ignorar colisão com o arqueiro que disparou a flecha
	if archer_parent and body == archer_parent:
		# print("Ignorando colisão com o arqueiro que disparou")
		return
	
	# Causar dano ao player se for ele
	if body.has_method("take_damage") and body.name == "MainPlayer":
		body.take_damage(1)
		# print("Dano causado ao player")
		queue_free()
	# Destrói flecha ao atingir qualquer coisa que não seja outro inimigo
	elif not body.is_in_group("enemy"):
		queue_free()
