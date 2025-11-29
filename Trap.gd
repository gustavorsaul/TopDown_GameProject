extends Node2D

@export var damage: int = 1
@export var active_time: float = 0.6     # tempo que a armadilha fica ativa
@export var inactive_time: float = 1.0   # tempo seguro entre ativações

var active: bool = false

@onready var sprite := $AnimatedSprite2D
@onready var area := $Area2D


var running := true

func _ready():
	area.body_entered.connect(_on_body_entered)
	sprite.play("one")
	sprite.frame = 0
	start_cycle()

func _exit_tree():
	running = false

func start_cycle() -> void:
	call_deferred("_cycle_loop")


func _cycle_loop() -> void:
	while running:
		active = false
		sprite.play("one")
		sprite.frame = 0
		if !is_inside_tree():
			return
		await get_tree().create_timer(inactive_time, false).timeout
		if !running or !is_inside_tree():
			return

		active = true
		sprite.play("one")
		sprite.frame = 2
		_check_for_player_on_trap()
		if !is_inside_tree():
			return
		await get_tree().create_timer(active_time, false).timeout



func _check_for_player_on_trap() -> void:
	var overlapping_bodies = area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				# print("Player tomou dano da trap ativa!")
			# else:
				# print("Dano causado ao jogador (simulação):", damage)

func _on_body_entered(body: Node) -> void:
	if active and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# else:
			# print("Dano causado ao jogador (simulação):", damage)
