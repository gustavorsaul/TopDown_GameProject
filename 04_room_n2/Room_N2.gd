extends Node2D
signal level_finished(next_scene_path: String)

@onready var lever := get_node_or_null("Lever")
@onready var return_home := get_node_or_null("ReturnHome")

@onready var door := $IronDoor

@onready var wooddoor := $WoodDoor

@onready var archer_count_label := get_node_or_null("Label")

@onready var sign_arrow := $MainPlayer/Camera2D/Sprite2D

var archers_alive := 0

func _ready():
	
	if door:
		door.close_door()
	
	if wooddoor:
		wooddoor.open_door()
		wooddoor.close_door()
	
	if lever:
		lever.connect("lever_activated", Callable(self, "_on_lever_activated"))
	if return_home:
		return_home.connect("body_entered", Callable(self, "_on_return_home_entered"))
		return_home.set_deferred("monitoring", false)
	
	# Conta os inimigos no início e conecta os sinais
	call_deferred("refresh_archers")

func refresh_archers() -> void:
	archers_alive = 0
	var archers = get_tree().get_nodes_in_group("room_n2_archers")

	for a in archers:
		# Verifica se o objeto é válido e não está marcado para ser deletado
		if is_instance_valid(a) and not a.is_queued_for_deletion():
			archers_alive += 1
			if not a.is_connected("archer_died", Callable(self, "_on_archer_died")):
				a.connect("archer_died", Callable(self, "_on_archer_died"))

	
	print("Inimigos vivos no inicio: %d" % archers_alive)
	
	# Atualiza o label com o número de arqueiros
	_update_archer_label()

	# Se começar sem inimigos, já abre a porta
	if archers_alive == 0:
		_open_door_now()

func _on_archer_died() -> void:
	# Reduz o contador
	archers_alive = max(0, archers_alive - 1)
	print("Tutorial: Archer derrotado! Restam: %d" % archers_alive)
	
	# Atualiza o label
	_update_archer_label()

	# Se acabaram os arqueiros, abre a porta
	if archers_alive == 0:
		_open_door_now()

func _update_archer_label() -> void:
	if archer_count_label:
		archer_count_label.text = str(archers_alive)

func _open_door_now() -> void:
	if door:
		door.open_door()
		door.set_as_top_level(true)
		print("Porta do tutorial liberada.")

func _on_lever_activated(room_id: String):
	print("Alavanca da", room_id, "ativada → liberando retorno.")
	wooddoor.open_door()
	if return_home:
		return_home.set_deferred("monitoring", true)
	
	if sign_arrow:
		sign_arrow.visible = true
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = false
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = true
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = false
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = true
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = false

func _on_return_home_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		GlobalVars.complete_room_part2(2)
			
		# Define o respawn do player ao voltar para Home
		GlobalVars.set_next_respawn(Vector2(285, 285))  
		
		print("Player voltou para a entrada → emitindo sinal para Home")
		emit_signal("level_finished", "res://02_home/Home.tscn")
