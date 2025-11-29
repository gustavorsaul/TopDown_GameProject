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
	await get_tree().create_timer(1.0).timeout
	area.body_entered.connect(_on_body_entered)
	sprite.play(animation_name)
	active = false
	_check_cycle_task()

func _exit_tree():
	# Marca para parar o loop quando o nó for removido
	active = false

func _check_cycle_task() -> void:
	# aguarda até o nó realmente estar dentro da árvore
	await ready

	while is_inside_tree():
		# segurança — evita nulls durante troca de cena
		var tree := get_tree()
		if tree == null:
			return

		var frame = sprite.frame
		active = frame >= active_start_frame and frame <= active_end_frame

		if active:
			_check_for_player_on_trap()

		# espera um pequeno intervalo antes de checar novamente
		await tree.create_timer(check_interval, false).timeout




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
