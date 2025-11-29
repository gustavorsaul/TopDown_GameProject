extends Node2D

signal level_finished(next_scene_path: String)

@onready var locker1 := $Locker1
@onready var locker2 := $Locker2
@onready var final_area := $Final
@onready var player := get_node("MainPlayer")

@onready var door1 := $WoodDoor
@onready var door2 := $WoodDoor2

@onready var iron_door := $IronDoor 

func _ready():
	var spawn_pos = GlobalVars.get_next_respawn()
	if spawn_pos != Vector2.ZERO:
		player.position = spawn_pos
	
	_connect_signals()
	
	_update_doors_state()
	
	_update_lockers_state() 

func _connect_signals() -> void:
	var room_n1 = get_node_or_null("Room_N1")
	if room_n1:
		if not room_n1.is_connected("body_entered", Callable(self, "_on_room_n1_body_entered")):
			room_n1.connect("body_entered", Callable(self, "_on_room_n1_body_entered"))

	var room_n2 = get_node_or_null("Room_N2")
	if room_n2:
		if not room_n2.is_connected("body_entered", Callable(self, "_on_room_n2_body_entered")):
			room_n2.connect("body_entered", Callable(self, "_on_room_n2_body_entered"))
			
	if final_area:
		if not final_area.is_connected("body_entered", Callable(self, "_on_final_body_entered")):
			final_area.connect("body_entered", Callable(self, "_on_final_body_entered"))

# Transições
func _on_room_n1_body_entered(body: Node) -> void:
	if body.name == "MainPlayer" and !GlobalVars.room_n1_part2:
		emit_signal("level_finished", "res://03_room_n1/Room_N1.tscn")

func _on_room_n2_body_entered(body: Node) -> void:
	if body.name == "MainPlayer" and !GlobalVars.room_n2_part2:
		emit_signal("level_finished", "res://04_room_n2/Room_N2.tscn")

func _on_final_body_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		# print("Player entrou no Final!")
		get_tree().change_scene_to_file("res://00_main/Finish.tscn")

# Updates Visuais e Lógicos
func _update_lockers_state() -> void:
	if locker1 and GlobalVars.locker1_open:
		locker1.play("open")

	if locker2 and GlobalVars.locker2_open:
		locker2.play("open")
	
	_check_final_area_activation()

func _update_doors_state() -> void:
	if door1:
		if GlobalVars.room_n1_part2:
			door1.open_door()
			door1.close_door()
		else:
			door1.open_door()

	if door2:
		if GlobalVars.room_n2_part2:
			door2.open_door()
			door2.close_door()
		else:
			door2.open_door()

# Lógica da Porta de Ferro e Final 
func _check_final_area_activation() -> void:
	
	if GlobalVars.locker1_open and GlobalVars.locker2_open:
		# print("Todas as condições atendidas. Abrindo final.")
		
		if final_area:
			final_area.set_deferred("monitoring", true)
		
		if iron_door:
			iron_door.open_door()
	else:
		
		if final_area:
			final_area.set_deferred("monitoring", false)
			
		if iron_door:
			iron_door.close_door()
