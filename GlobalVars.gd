extends Node

# Variáveis do player
var player_lives = 3
var player_attempts = 1



# Estado das salas (false = não concluída, true = concluída)
var room_n1_part1 = false
var room_n2_part1 = false

# Estado das salas (false = não concluída, true = concluída)
var room_n1_part2 = false
var room_n2_part2 = false

# Controle de respawn
var tutorial_completed = false  # Quando true, o respawn será na Home

# Estado dos lockers na Home
var locker1_open = false  # Corresponde à Room N1
var locker2_open = false  # Corresponde à Room N2

# Funções relacionadas ao dash
var dash_number = 2
var dash_max: int = 2

var _dash_timer: Timer

func _ready():
	# Cria e configura o Timer
	_dash_timer = Timer.new()
	_dash_timer.wait_time = 2.0  # 1 segundo
	_dash_timer.one_shot = false
	_dash_timer.autostart = true
	add_child(_dash_timer)
	
	# Conecta o timeout
	_dash_timer.timeout.connect(_increment_dash_number)

# Função que incrementa dash_number
func _increment_dash_number() -> void:
	if dash_number < dash_max:
		dash_number += 1
		print("Dash number incrementado: ", dash_number)



# Funções para gerenciar vidas e tentativas do player
func get_player_lives():
	return player_lives

func get_player_attempts():
	return player_attempts

func reset_player_stats():
	player_lives = 10
	player_attempts = 0

# Função para marcar uma sala como concluída
func complete_room(room_number):
	match room_number:
		1:
			room_n1_part1 = true
		2:
			room_n2_part1 = true
			
			
# Função para marcar uma sala como concluída
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

# Função para verificar se uma sala está concluída
func is_room_completed(room_number):
	match room_number:
		1:
			return room_n1_part2
		2:
			return room_n2_part2
	return false

# Função para completar o tutorial
func complete_tutorial():
	tutorial_completed = true

# Função para obter o ponto de respawn
func get_respawn_scene():
	if tutorial_completed:
		return "res://02_home/Home.tscn"
	else:
		return "res://01_tutorial/Tutorial.tscn"

# Função para reduzir vidas do player
func reduce_player_life(amount=1):
	player_lives -= amount
	print("[GlobalVars] Vidas restantes: ", player_lives)
	return player_lives

func handle_attempt_reset():
	player_attempts += 1
	print("[GlobalVars] Tentativa atual:", player_attempts)
	
	if player_attempts > 3:
		reset_player_stats()
		print("[GlobalVars] GAME OVER - Estatísticas resetadas")
		get_tree().change_scene_to_file("res://00_main/GameOver.tscn")
	else:
		player_lives = 3
		print("[GlobalVars] Vidas resetadas para 3 (Tentativa ", player_attempts, " de 3)")
