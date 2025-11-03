

extends Node2D

signal level_finished(next_scene_path: String)

func _ready():

	# Conecta os sinais manualmente (para evitar loops automáticos)
	var home = get_node_or_null("Area2D")
	if home:
		home.connect("body_entered", Callable(self, "_on_home_body_entered"))
	

# --- Funções de transição individual --- #	

func _on_home_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		# Marca o tutorial como concluído no GlobalVars
		GlobalVars.complete_tutorial()
		print("Player entrou na Home → indo para Home.tscn")
		#get_tree().change_scene_to_file("res://02_home/Home.tscn")
		emit_signal("level_finished", "res://02_home/Home.tscn")
		
