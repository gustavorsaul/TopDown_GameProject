extends Node2D

func _ready():
	# Conecta os sinais manualmente
	var home_area = get_node_or_null("Area2D")
	if home_area:
		home_area.connect("body_entered", Callable(self, "_on_home_body_entered"))

# Função chamada quando o jogador entra na área de saída
func _on_home_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		# Marca a Room N1 como concluída no GlobalVars
		GlobalVars.complete_room("room_n1")
		print("Player completou a Room N1 → voltando para Home")
		get_tree().change_scene_to_file("res://02_home/Home.tscn")