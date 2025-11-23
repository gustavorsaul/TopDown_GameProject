extends Node2D

@onready var player := $Tutorial/MainPlayer
var current_scene : Node2D = null

# --- REFERÊNCIAS PARA AS BARRAS ---
# HP (Vida do personagem dentro do nível)
@onready var bar_hp := $HUD/HP_Count/TextureRect/TextureProgressBar
# LIVES (Vidas totais/Tentativas restantes)
@onready var bar_lives := $HUD/Lives_Count/TextureRect/TextureProgressBar
# DASH (Stamina do dash)
@onready var bar_dash := $HUD/Dash_Count/TextureRect/TextureProgressBar

func _ready() -> void:
	# --- CONFIGURAÇÃO INICIAL DAS BARRAS ---
	
	# DASH: Vai de 0 a 2 (conforme seu pedido)
	if bar_dash:
		bar_dash.max_value = 2
		bar_dash.value = 2 # Começa cheia ou com o valor atual do GlobalVars
	
	# LIVES: Configura o máximo de vidas (ex: 3 ou 5)
	if bar_lives:
		# Defina aqui qual é o máximo de vidas que o jogador pode ter
		bar_lives.max_value = 3 
		bar_lives.value = 3
		
	# HP: Configura a vida dentro da fase
	if bar_hp:
		bar_hp.max_value = 3 # Exemplo
	
	# --- LÓGICA DE INICIALIZAÇÃO DA CENA ---
	current_scene = get_node_or_null("Tutorial")
	if current_scene:
		player = current_scene.get_node_or_null("MainPlayer")
		print("Tutorial carregado automaticamente:", current_scene.name)
		_connect_scene_signals()
	
	# Atualiza visualmente logo no início
	update_hud_visuals()
	
	await get_tree().process_frame
	await Transition.fade_in()

func _physics_process(delta: float) -> void:
	if player == null and current_scene != null:
		player = current_scene.get_node_or_null("MainPlayer")
		if player:
			_connect_player_signal()

	# Mantém a HUD atualizada a cada frame
	update_hud_visuals()

# --- ATUALIZAÇÃO DA HUD ---
func update_hud_visuals() -> void:
	# 1. ATUALIZA DASH EM TEMPO REAL
	if bar_dash:
		# Pega o número inteiro de dashes (ex: 0 ou 1)
		var dashes_atuais = float(GlobalVars.dash_number)
		
		# Pega a fração do próximo dash carregando (ex: 0.5)
		var progresso_recarga = GlobalVars.get_dash_recharge_progress()
		
		# Soma tudo. Ex: 1 dash + 0.5 recarga = 1.5 na barra
		bar_dash.value = dashes_atuais + progresso_recarga
		
	# 2. ATUALIZA LIVES (Barra Vermelha)
	if bar_lives:
		bar_lives.value = GlobalVars.get_remaining_attempts_for_hud()
	
	# 3. ATUALIZA HP (Barra Verde)
	if bar_hp:
		bar_hp.value = GlobalVars.get_player_lives()

# --- Funções auxiliares (Sinais e Transição) ---

func _connect_scene_signals() -> void:
	if current_scene and current_scene.has_signal("level_finished"):
		if not current_scene.is_connected("level_finished", Callable(self, "_on_level_finished")):
			current_scene.connect("level_finished", Callable(self, "_on_level_finished"))
	_connect_player_signal()

func _connect_player_signal() -> void:
	if player and player.has_signal("player_died"):
		if not player.is_connected("player_died", Callable(self, "_on_player_died")):
			player.connect("player_died", Callable(self, "_on_player_died"))

func go_to_scene(path : String):
	await Transition.fade_out()
	
	if current_scene:
		current_scene.queue_free()

	var res := ResourceLoader.load(path)
	current_scene = res.instantiate()
	add_child(current_scene)

	player = current_scene.get_node_or_null("MainPlayer")
	_connect_scene_signals()
	
	await Transition.fade_in()

func _on_level_finished(next_scene_path: String):
	go_to_scene(next_scene_path)

func _on_player_died(respawn_path: String):
	go_to_scene(respawn_path)
