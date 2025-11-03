extends Node2D

signal level_finished(next_scene_path: String)

@onready var end_area := $Area2D
@onready var return_home := $ReturnHome

func _ready():
	# Conecta o sinal do final da sala
	if end_area:
		end_area.connect("body_entered", Callable(self, "_on_end_area_entered"))

	# Conecta o sinal da área de retorno
	if return_home:
		return_home.connect("body_entered", Callable(self, "_on_return_home_entered"))
		return_home.set_deferred("monitoring", true)  # já ativada

# --- Quando o player chega ao final da sala ---
func _on_end_area_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player chegou ao final da sala!")

# --- Quando o player retorna para a entrada ---
func _on_return_home_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		GlobalVars.complete_room_part2(2)
		print("Player voltou → emitindo sinal para Home")
		emit_signal("level_finished", "res://02_home/Home.tscn")
