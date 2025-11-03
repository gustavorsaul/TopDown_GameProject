extends Node2D

@onready var player := $Tutorial/MainPlayer
var current_scene : Node2D = null
@onready var life_label := $HUD/Vida
@onready var attempts_label := $HUD/Tentativas
@onready var dash_number := $HUD/DashCount

func _ready() -> void:
	get_tree().call_group("MainPlayer", "print_position")
	current_scene = get_node("Tutorial")
	player = current_scene.get_node_or_null("MainPlayer")

	print("Tutorial carregado automaticamente:", current_scene.name)

	# Conectar sinais da cena e do player
	_connect_scene_signals()
	update_hud_labels()

func _physics_process(delta: float) -> void:
	if player == null and current_scene != null:
		player = current_scene.get_node("MainPlayer")
		_connect_player_signal() # reconecta o signal se o player for recriado

	update_hud_labels()

func update_hud_labels() -> void:
	if life_label:
		life_label.text = "Vidas: " + str(GlobalVars.get_player_lives())
	if attempts_label:
		attempts_label.text = "Tentativa: " + str(GlobalVars.get_player_attempts())
	if dash_number:
		dash_number.text = "Dash: " + str(GlobalVars.dash_number)
# --- Funções auxiliares --- #

func _connect_scene_signals() -> void:
	if current_scene.has_signal("level_finished"):
		current_scene.connect("level_finished", Callable(self, "_on_level_finished"))
	_connect_player_signal()

func _connect_player_signal() -> void:
	if player and player.has_signal("player_died"):
		player.connect("player_died", Callable(self, "_on_player_died"))

# --- Troca de cena sem destruir HUD --- #

func go_to_scene(path : String):
	print("Going to Scene: " + path)
	if current_scene:
		current_scene.queue_free()

	var res := ResourceLoader.load(path)
	current_scene = res.instantiate()
	add_child(current_scene)

	player = current_scene.get_node_or_null("MainPlayer")

	# Conecta os sinais de cena e player novamente
	_connect_scene_signals()

# --- Callbacks de sinais --- #

func _on_level_finished(next_scene_path: String):
	go_to_scene(next_scene_path)

func _on_player_died(respawn_path: String):
	print("Player morreu → Respawn em:", respawn_path)
	go_to_scene(respawn_path)
