extends Node2D

signal lever_activated(room_id: String)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

@onready var button: Sprite2D = $Sprite2D

# Define em qual sala a alavanca está (editável no editor)
@export var room_id: String = "room_n1"

# Controle interno
var can_interact: bool = false
var activated: bool = false

func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	if can_interact and not activated and Input.is_action_just_pressed("interact"):
		activate_lever()

func _on_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		can_interact = true
		print("Player pode interagir com a alavanca da", room_id)
		button.visible = true
		

func _on_body_exited(body: Node) -> void:
	if body.name == "MainPlayer":
		can_interact = false
		button.visible = false

func activate_lever():
	activated = true
	sprite.play("activate")

	# Ação global
	GlobalVars.complete_room(room_id)
	
	print("Alavanca ativada na sala:", room_id)
	emit_signal("lever_activated", room_id)
