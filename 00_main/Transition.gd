extends CanvasLayer

@onready var rect := $ColorRect
var fade_time := 0.3  # duração do fade (em segundos)

func _ready():
	rect.modulate.a = 0.0
	# Se quiser um fade-in ao iniciar o jogo:
	await get_tree().process_frame

func fade_in() -> void:
	rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, fade_time)
	await tween.finished

func fade_out() -> void:
	rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, fade_time)
	await tween.finished
