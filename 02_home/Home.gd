extends Node2D

signal level_finished(next_scene_path: String)

@onready var locker1 := $Locker1
@onready var locker2 := $Locker2
@onready var final_area := $Final

func _ready():
	# Conecta as áreas de transição para salas
	var room_n1 = get_node_or_null("Room_N1")
	if room_n1:
		room_n1.connect("body_entered", Callable(self, "_on_room_n1_body_entered"))

	var room_n2 = get_node_or_null("Room_N2")
	if room_n2:
		room_n2.connect("body_entered", Callable(self, "_on_room_n2_body_entered"))
	
	# Inicializa os lockers
	_update_lockers_state()
	
	# Configura a Final
	if final_area:
		final_area.set_deferred("monitoring", false)  # Começa desativada
		final_area.connect("body_entered", Callable(self, "_on_final_body_entered"))
	
	# Verifica se os lockers estão abertos e ativa a Final se necessário
	_check_final_area_activation()

# --- Transições individuais --- #

func _on_room_n1_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou na Sala N1 → emitindo sinal para carregar Room_N1.tscn")
		emit_signal("level_finished", "res://03_room_n1/Room_N1.tscn")

func _on_room_n2_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou na Sala N2 → emitindo sinal para carregar Room_N2.tscn")
		emit_signal("level_finished", "res://04_room_n2/Room_N2.tscn")

func _on_final_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		print("Player entrou no Final!")
		get_tree().change_scene_to_file("res://00_main/Finish.tscn")

# --- Atualiza os lockers com base em variáveis globais --- #
func _update_lockers_state() -> void:
	if locker1 and GlobalVars.locker1_open:
		locker1.play("open")

	if locker2 and GlobalVars.locker2_open:
		locker2.play("open")
	
	# Após atualizar lockers, checa se a Final pode ser ativada
	_check_final_area_activation()

# --- Ativa a Final se ambos os lockers estiverem abertos --- #
func _check_final_area_activation() -> void:
	if locker1 and locker2 and final_area:
		if GlobalVars.locker1_open and GlobalVars.locker2_open:
			final_area.set_deferred("monitoring", true)
			print("Área Final ativada! Player pode acessar o final da Home.")
		else:
			final_area.set_deferred("monitoring", false)
