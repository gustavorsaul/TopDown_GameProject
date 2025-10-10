extends Node2D

@export var damage := 10
@export var active_time := 0.5
@export var inactive_time := 1.0

var active := false

func _ready():
	$AnimatedSprite2D.play("idle")
	_cycle_trap()

func _cycle_trap():
	while true:
		active = false
		$AnimatedSprite2D.play("idle")
		await get_tree().create_timer(inactive_time).timeout

		active = true
		$AnimatedSprite2D.play("attack")
		await get_tree().create_timer(active_time).timeout
