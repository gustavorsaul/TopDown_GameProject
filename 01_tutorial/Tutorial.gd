extends Node2D

signal level_finished(next_scene_path: String)

var archer_alive := true  # controla se o inimigo ainda está vivo

func _ready():
	
	# Conecta o sinal da área de transição (home)
	var home = get_node_or_null("Area2D")
	if home:
		home.connect("body_entered", Callable(self, "_on_home_body_entered"))

	# Procura o Archer instanciado nesta cena
	var archer = get_node_or_null("Archer")
	if archer:
		# Conecta o sinal de morte do Archer ao método local
		if not archer.is_connected("archer_died", Callable(self, "_on_archer_died")):
			archer.connect("archer_died", Callable(self, "_on_archer_died"))
	else:
		# Caso o Archer não exista (ex: em teste), libera a passagem
		archer_alive = false


func _on_archer_died() -> void:
	print("Tutorial: Archer derrotado!")
	archer_alive = false


func _on_home_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		if archer_alive:
			print("Ainda há inimigos vivos! Mate o Archer primeiro.")
			return

		# Tutorial concluído → libera transição
		GlobalVars.complete_tutorial()
		print("Player entrou na Home → indo para Home.tscn")
		emit_signal("level_finished", "res://02_home/Home.tscn")
