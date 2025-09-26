extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play()
	
func animation_finished():
	print("Acabou a animação")
	queue_free()
