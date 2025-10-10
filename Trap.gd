extends Node2D

@export var damage: int = 1
@export var active_time: float = 0.6     # tempo que a armadilha fica "ativa" (dando dano)
@export var inactive_time: float = 1.0   # tempo "seguro" entre ativações

var active: bool = false

@onready var sprites := [
	$AnimatedSprite2D,
	$AnimatedSprite2D2,
	$AnimatedSprite2D3,
	$AnimatedSprite2D4
]

@onready var area := $Area2D


func _ready():
	# Conecta o sinal de colisão
	area.body_entered.connect(_on_body_entered)

	# Garante que todas as animações começam sincronizadas
	for s in sprites:
		s.play("one")
		s.frame = 0
		s.frame_progress = 0

	# Inicia o ciclo contínuo de "abrir e fechar"
	start_cycle()


func start_cycle() -> void:
	# Cria uma coroutine separada com await — Godot 4 permite isso assim:
	call_deferred("_cycle_loop")


func _cycle_loop() -> void:
	while true:
		# Fase inativa
		active = false
		for s in sprites:
			s.play("one")
			s.frame = 0
		await get_tree().create_timer(inactive_time).timeout

		# Fase ativa
		active = true
		for s in sprites:
			s.play("one")
			s.frame = 2   # ajuste conforme o frame "letal" da animação
		
		# Verifica se há player em cima da trap quando ela se ativa
		_check_for_player_on_trap()
		
		await get_tree().create_timer(active_time).timeout


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
