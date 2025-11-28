extends Node2D

@export var speed: float = 400.0         # velocidade da lâmina
@export var damage: int = 1              # dano causado ao player
@export var reverse: bool = true         # se a lâmina vai e volta

@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var sprite: AnimatedSprite2D = $Path2D/PathFollow2D/AnimatedSprite2D
@onready var area: Area2D = $Path2D/PathFollow2D/Area2D

var direction: int = 1   # 1 = indo, -1 = voltando


func _ready():
	sprite.play("move")
	area.body_entered.connect(_on_body_entered)
	set_process(true)


func _process(delta: float) -> void:
	# movimenta a lâmina ao longo do Path2D
	path_follow.progress += speed * delta * direction

	# se reverse estiver ativado, inverte ao chegar no fim/início
	if reverse:
		if path_follow.progress_ratio >= 1.0:
			direction = -1
		elif path_follow.progress_ratio <= 0.0:
			direction = 1
	else:
		# caso contrário, reinicia no começo
		if path_follow.progress_ratio >= 1.0:
			path_follow.progress_ratio = 0.0


func _on_body_entered(body: Node) -> void:
	# aplica dano se o corpo for o player
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Player atingido pela lâmina! Dano:", damage)
		else:
			print("Player atingido (simulação):", damage)
