extends Node2D

signal level_finished(next_scene_path: String)

var archers_alive := 0
@onready var door := $WoodDoor

func _ready():
	# 1. Garante estado inicial da porta
	# Como o script da porta corrigido já lida com a colisão no close_door, 
	# basta chamar close_door().
	if door:
		door.close_door()

	# Conecta área de transição (Saída do nível)
	var home = get_node_or_null("Area2D")
	if home:
		if not home.is_connected("body_entered", Callable(self, "_on_home_body_entered")):
			home.connect("body_entered", Callable(self, "_on_home_body_entered"))

	# Conta os inimigos no início
	call_deferred("refresh_archers")

func refresh_archers() -> void:
	archers_alive = 0
	var archers = get_tree().get_nodes_in_group("tutorial_archers")

	for a in archers:
		# Verifica se o objeto é válido e não está marcado para ser deletado
		if is_instance_valid(a) and not a.is_queued_for_deletion():
			archers_alive += 1
			if not a.is_connected("archer_died", Callable(self, "_on_archer_died")):
				a.connect("archer_died", Callable(self, "_on_archer_died"))
	
	print("Inimigos vivos no inicio: %d" % archers_alive)

	# Se começar sem inimigos, já abre a porta
	if archers_alive == 0:
		_open_door_now()

func _on_archer_died() -> void:
	# Reduz o contador
	archers_alive = max(0, archers_alive - 1)
	print("Tutorial: Archer derrotado! Restam: %d" % archers_alive)

	# Se acabaram os arqueiros, abre a porta
	if archers_alive == 0:
		_open_door_now()

func _open_door_now() -> void:
	if door:
		door.open_door()
		print("Porta do tutorial liberada.")

func _on_home_body_entered(body: Node) -> void:
	# Verifica se é o player
	if body.name != "MainPlayer":
		return

	# Verificação de segurança final
	if archers_alive > 0:
		print("Ainda há arqueiros vivos. A porta não deveria estar aberta ou você pulou a parede!")
		return

	# Finaliza o nível
	# (Assumindo que GlobalVars existe no seu projeto)
	if GlobalVars:
		GlobalVars.complete_tutorial()
	
	emit_signal("level_finished", "res://02_home/Home.tscn")
