#extends Node2D
#
#var room_scene_paths = {
	#"Room_N1": "res://03_room_n1/Room_N1.tscn",
	#"Room_N2": "res://04_room_n2/Room_N2.tscn",
	#"Room_N3": "res://05_room_n3/Room_N3.tscn",
	#"Room_N4": "res://06_room_n4/Room_N4.tscn"
#}
#
#func _ready():
	## Conecta dinamicamente os sinais das áreas
	#for room_name in room_scene_paths.keys():
		#var room = get_node(room_name)
		#if room:
			#room.connect("body_entered", Callable(self, "_on_room_entered"))
#
	## Ativa a visualização das colisões
#
#func _on_room_entered(body):
	#if body.name == "MainPlayer":
		#var room_name = body.get_parent().name if body.get_parent() else ""
		#if room_name in room_scene_paths:
			#var scene_path = room_scene_paths[room_name]
			#print("Entrando em %s..." % room_name)
			#get_tree().change_scene_to_file(scene_path)


extends Node2D

func _ready():

	# Conecta os sinais manualmente (para evitar loops automáticos)
	var room_n1 = get_node_or_null("Room_N1")
	if room_n1:
		room_n1.connect("body_entered", Callable(self, "_on_room_n1_body_entered"))

	var room_n2 = get_node_or_null("Room_N2")
	if room_n2:
		room_n2.connect("body_entered", Callable(self, "_on_room_n2_body_entered"))

	var room_n3 = get_node_or_null("Room_N3")
	if room_n3:
		room_n3.connect("body_entered", Callable(self, "_on_room_n3_body_entered"))

	var room_n4 = get_node_or_null("Room_N4")
	if room_n4:
		room_n4.connect("body_entered", Callable(self, "_on_room_n4_body_entered"))


# --- Funções de transição individual --- #

func _on_room_n1_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou na Sala N1 → indo para cena_1.tscn")
		get_tree().change_scene_to_file("res://03_room_n1/Room_N1.tscn")


func _on_room_n2_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou na Sala N2 → indo para cena_2.tscn")
		get_tree().change_scene_to_file("res://04_room_n2/Room_N2.tscn")


func _on_room_n3_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou na Sala N3 → indo para cena_3.tscn")
		get_tree().change_scene_to_file("res://05_room_n3/Room_N3.tscn")


func _on_room_n4_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou na Sala N4 → indo para cena_4.tscn")
		get_tree().change_scene_to_file("res://06_room_n4/Room_N4.tscn")
