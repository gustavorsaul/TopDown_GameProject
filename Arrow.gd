extends Area2D

@export var speed = 500.0
var target: Vector2

func _ready() -> void:
	$AnimatedSprite2D.play()
	# Conectar sinais de colisão
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _physics_process(delta: float) -> void:
	look_at(target)
	var velocity = position.direction_to(target)
	if position.distance_to(target) > 10:
		position += velocity * speed * delta
	else:
		queue_free()
		
	
func animation_finished():
	print("Acabou a animação")
	queue_free()

func _on_body_entered(body: Node) -> void:
	# Verifica se o corpo é um inimigo que pode receber dano
	if body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
