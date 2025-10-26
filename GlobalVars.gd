extends Node

# Variáveis do player
var player_lives = 3
var player_attempts = 0

# Estado das salas (false = não concluída, true = concluída)
var room_n1_completed = false
var room_n2_completed = false
var room_n3_completed = false
var room_n4_completed = false

# Controle de respawn
var tutorial_completed = false  # Quando true, o respawn será na Home

# Estado dos lockers na Home
var locker1_open = false  # Corresponde à Room N1
var locker2_open = false  # Corresponde à Room N2
var locker3_open = false  # Corresponde à Room N3
var locker4_open = false  # Corresponde à Room N4

# Funções para gerenciar vidas e tentativas do player
func get_player_lives():
	return player_lives

func get_player_attempts():
	return player_attempts

func reset_player_stats():
	player_lives = 3
	player_attempts = 0

# Função para marcar uma sala como concluída
func complete_room(room_number):
	match room_number:
		1:
			room_n1_completed = true
			locker1_open = true
		2:
			room_n2_completed = true
			locker2_open = true
		3:
			room_n3_completed = true
			locker3_open = true
		4:
			room_n4_completed = true
			locker4_open = true

# Função para verificar se uma sala está concluída
func is_room_completed(room_number):
	match room_number:
		1:
			return room_n1_completed
		2:
			return room_n2_completed
		3:
			return room_n3_completed
		4:
			return room_n4_completed
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
	
	if player_lives <= 0:
		player_attempts += 1
		print("[GlobalVars] Tentativa atual: ", player_attempts)
		
		if player_attempts >= 3:
			# Game over - resetar tudo
			reset_player_stats()
			print("[GlobalVars] GAME OVER - Estatísticas resetadas")
		else:
			# Apenas resetar as vidas para a próxima tentativa
			player_lives = 3
			print("[GlobalVars] Vidas resetadas para 3 (Tentativa ", player_attempts, " de 3)")
	
	return player_lives
