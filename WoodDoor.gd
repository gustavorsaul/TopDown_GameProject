extends Node2D

@onready var anim := $AnimatedSprite2D

@onready var col := $StaticBody2D/CollisionShape2D 

@onready var col1 = $StaticBody2D2/CollisionShape2D
@onready var col2 = $StaticBody2D2/CollisionShape2D2

var is_open := false

func _ready():
	col1.disabled = false
	col2.disabled = false

func open_door():
	if not is_open:
		anim.play("opening")
		col.set_deferred("disabled", true)
		is_open = true

func close_door():
	if is_open:
		anim.play("closing")
		col.set_deferred("disabled", false)
		is_open = false
