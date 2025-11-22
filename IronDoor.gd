extends Node2D

@onready var anim := $AnimatedSprite2D
# Ajustei o caminho assumindo que você mudou para StaticBody2D
# Se manteve Area2D, mude "StaticBody2D" para "Area2D" abaixo
@onready var col := $StaticBody2D/CollisionShape2D 

var is_open := false

func open_door():
	if not is_open:
		anim.play("opening")
		# "set_deferred" é OBRIGATÓRIO para evitar erros de física ao alterar colisões em tempo real
		col.set_deferred("disabled", true)
		is_open = true

func close_door():
	if is_open:
		anim.play("closing")
		# Reativa a colisão de forma segura
		col.set_deferred("disabled", false)
		is_open = false
