extends Node2D

signal level_finished(next_scene_path: String)

@onready var end_area := get_node_or_null("Area2D")
@onready var return_home := get_node_or_null("ReturnHome")

func _ready():
	# Conecta o sinal do final da sala
	if end_area:
		end_area.connect("body_entered", Callable(self, "_on_end_area_entered"))
	
	# Conecta o sinal da área de retorno, mas deixa ela desativada
	if return_home:
		return_home.connect("body_entered", Callable(self, "_on_return_home_entered"))
		return_home.set_deferred("monitoring", false)  # começa desativado

# --- Quando o player chega ao final da sala ---
func _on_end_area_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		GlobalVars.complete_room("room_n1")
		print("Player completou a Room N1 → ativando retorno!")
		
		# Ativa a área de retorno
		if return_home:
			return_home.set_deferred("monitoring", true)
			print("Área de retorno agora está ativa!")

# --- Quando o player retorna para a entrada ---
func _on_return_home_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		GlobalVars.complete_room_part2(1)
		print("Player voltou para a entrada → emitindo sinal para Home")
		emit_signal("level_finished", "res://02_home/Home.tscn")
