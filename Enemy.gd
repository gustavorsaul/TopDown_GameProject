extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var life_label = $Life

var previous_position: Vector2
var life: int = 3

func  _ready() -> void:
	previous_position = position
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("new_animation")
	_update_life_label()

func _physics_process(delta: float) -> void:
	life_label.text = "Vida: " + str(life) 
	# Only use velocity-based animation when actually moving via physics
	if velocity.length() > 0.01:
		animate()

func _process(delta: float) -> void:
	# Use position delta to animate when moved externally (e.g., AnimationPlayer)
	var movement: Vector2 = position - previous_position
	if movement.length() < 0.1:
		sprite.stop()
		previous_position = position
		return
	if abs(movement.x) > abs(movement.y):
		if movement.x > 0:
			sprite.play("right")
		else:
			sprite.play("left")
	else:
		if movement.y > 0:
			sprite.play("down")
		else:
			sprite.play("up")
	previous_position = position

func animate():
	
	if velocity.x > 0:
		sprite.play("right")
	elif velocity.x < 0:
		sprite.play("left")
	elif velocity.y > 0:
		sprite.play("down")
	elif velocity.y < 0:
		sprite.play("up")
	else:
		sprite.stop()

func take_damage(amount: int) -> void:
	life = max(0, life - amount)
	_update_life_label()
	if life == 0:
		die()

func die() -> void:
	queue_free()

func _update_life_label() -> void:
	if is_instance_valid(life_label):
		life_label.text = str(life)
