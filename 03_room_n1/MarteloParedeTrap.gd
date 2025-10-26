extends Node2D

@export var damage: int = 1
@export var active_start_frame: int = 2    # frame onde a trap começa a causar dano
@export var active_end_frame: int = 3      # frame onde a trap para de causar dano
@export var check_interval: float = 0.05   # intervalo para checar frames
@export var animation_name: String = "default"

var active: bool = false

@onready var sprite := $AnimatedSprite2D
@onready var area := $Area2D


func _ready():
	# Conecta o sinal de colisão
	area.body_entered.connect(_on_body_entered)

	# Inicia a animação contínua
	sprite.play(animation_name)
	active = false

	# Começa a checar o frame atual da animação em loop
	_check_cycle()


func _check_cycle() -> void:
	# Cria uma task em loop pra sincronizar com os frames da animação
	await get_tree().create_timer(check_interval).timeout

	var frame = sprite.frame

	# Ativa dano somente dentro do intervalo de frames definido
	if frame >= active_start_frame and frame <= active_end_frame:
		if not active:
			active = true
			_check_for_player_on_trap()
	else:
		active = false

	# Continua o loop indefinidamente
	_check_cycle()


func _check_for_player_on_trap() -> void:
	# Verifica todos os corpos que estão atualmente dentro da área da trap
	var overlapping_bodies = area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("Player tomou dano da trap ativa!")
			else:
				print("Dano causado ao jogador (simulação):", damage)


func _on_body_entered(body: Node) -> void:
	if active and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			print("Dano causado ao jogador (simulação):", damage)
