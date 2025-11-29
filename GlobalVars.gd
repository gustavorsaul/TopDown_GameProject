extends Node

# --- Configurações de Balanceamento ---
const MAX_LIVES = 3      # HP do player (Barra Verde)
const MAX_ATTEMPTS = 3   # Quantas "fichas"/vidas totais o jogo tem (Barra Vermelha)
const DASH_REGEN_TIME = 2.0 
const DASH_MAX_LIMIT = 2 # Constante para facilitar (usado para reset)

# --- Variáveis do Player ---
var player_lives = MAX_LIVES
var player_attempts = 1

# --- Dash ---
var dash_number = 2
var dash_max: int = 2
var _dash_timer: Timer

# --- Navegação e Respawn ---
var current_room: String = ""
var next_respawn_position: Vector2 = Vector2.ZERO
var tutorial_completed = false

# --- Estado das Salas (Progresso) ---
# Parte 1 (Conclusão básica)
var room_n1_part1 = false
var room_n2_part1 = false
# Parte 2 (Conclusão total/Lockers)
var room_n1_part2 = false
var room_n2_part2 = false

# --- Estado dos Lockers (Home) ---
var locker1_open = false
var locker2_open = false


func _ready():
	# Configura Timer do Dash
	_dash_timer = Timer.new()
	_dash_timer.wait_time = DASH_REGEN_TIME
	
	# MUDANÇA: Timer não roda sozinho. Ele espera o uso do dash.
	_dash_timer.one_shot = true 
	_dash_timer.autostart = false 
	
	add_child(_dash_timer)
	_dash_timer.timeout.connect(_increment_dash_number)

# --- NOVA LÓGICA DE DASH ---

# Chame esta função no script do Player quando apertar o botão de dash
# Ex: if GlobalVars.use_dash(): executa_dash()
func use_dash() -> bool:
	if dash_number > 0:
		dash_number -= 1
		print("Dash usado! Restantes: ", dash_number)
		
		# Se o timer estiver parado, inicia ele agora.
		# Se já estiver rodando (recuperando um dash anterior), deixa ele continuar.
		if _dash_timer.is_stopped():
			_dash_timer.start()
		
		return true # Dash permitido
	return false # Dash negado

# Retorna a porcentagem de recarga do dash atual (de 0.0 a 1.0)
func get_dash_recharge_progress() -> float:
	# Se o timer estiver parado, significa que não está carregando nada agora
	if _dash_timer.is_stopped():
		return 0.0
	
	# Cálculo: (Tempo Total - Tempo Restante) / Tempo Total
	# Exemplo: Se tempo total é 2s e falta 1s, o resultado é 0.5 (50%)
	return 1.0 - (_dash_timer.time_left / _dash_timer.wait_time)

func _increment_dash_number() -> void:
	if dash_number < dash_max:
		dash_number += 1
		print("Dash recarregado: ", dash_number)
		
		# Lógica de Recarga em Cadeia:
		# Se recuperou um, mas ainda cabe mais (ex: foi de 0 pra 1, mas max é 2),
		# reinicia o timer para buscar o próximo.
		if dash_number < dash_max:
			_dash_timer.start()

# --- HUD & Getters ---

func get_player_lives():
	return player_lives

# Retorna valor visual para a barra vermelha (3, 2, 1...)
func get_remaining_attempts_for_hud():
	var visual_value = (MAX_ATTEMPTS - player_attempts) + 1
	return max(0, visual_value)

func get_player_attempts():
	return player_attempts

# --- Lógica de Dano e Reset ---

func reduce_player_life(amount=1):
	player_lives -= amount
	print("[GlobalVars] HP restante: ", player_lives)
	return player_lives

func handle_attempt_reset():
	player_attempts += 1
	print("[GlobalVars] Tentativa atual:", player_attempts)
	
	if player_attempts > MAX_ATTEMPTS:
		print("[GlobalVars] GAME OVER")
		# Reseta estatísticas para o futuro
		reset_game_completely()
		call_deferred("_change_to_game_over")
	else:
		player_lives = MAX_LIVES
		dash_number = dash_max
		print("[GlobalVars] Vidas resetadas para 3.")

func _change_to_game_over():
	await get_tree().create_timer(1.3).timeout
	get_tree().change_scene_to_file("res://00_main/GameOver.tscn")

func reset_game_completely():
	player_lives = MAX_LIVES
	player_attempts = 1
	dash_number = DASH_MAX_LIMIT

	# Reset total do progresso
	room_n1_part1 = false
	room_n2_part1 = false
	room_n1_part2 = false
	room_n2_part2 = false

	# Reset dos lockers
	locker1_open = false
	locker2_open = false

	# Reset do tutorial
	tutorial_completed = false

	# Reset do respawn e sala atual (IMPORTANTE!)
	current_room = ""
	next_respawn_position = Vector2.ZERO

func reset_player_stats():
	# Mantido para compatibilidade se você usa em outro lugar
	reset_game_completely()

# --- Gerenciamento de Salas e Respawn ---

func set_next_respawn(pos: Vector2):
	next_respawn_position = pos

func get_next_respawn() -> Vector2:
	return next_respawn_position

func complete_room(room_number):
	match room_number:
		1: room_n1_part1 = true
		2: room_n2_part1 = true

func complete_room_part2(room_number):
	match room_number:
		1:
			room_n1_part2 = true
			locker1_open = true
			print("Room_N1 complete and locker 1 open!")
		2:
			room_n2_part2 = true
			locker2_open = true
			print("Room_N2 complete and locker 2 open!")

func is_room_completed(room_number):
	match room_number:
		1: return room_n1_part2
		2: return room_n2_part2
	return false

func complete_tutorial():
	tutorial_completed = true

func get_respawn_scene():
	if tutorial_completed:
		return "res://02_home/Home.tscn"
	else:
		return "res://01_tutorial/Tutorial.tscn"
