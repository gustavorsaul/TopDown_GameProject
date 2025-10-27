extends Node2D

@onready var player := $Tutorial/MainPlayer
var current_scene : Node2D = null
@onready var life_label := $HUD/Vida
@onready var attempts_label := $HUD/Tentativas

func _ready() -> void:
	get_tree().call_group("MainPlayer", "print_position")
	current_scene = get_node("Tutorial")
	
	player = current_scene.get_node_or_null("MainPlayer")
	print("Tutorial carregado automaticamente: ", current_scene.name)
	
	# Inicializa HUD
	update_hud_labels()
	
func _physics_process(delta: float) -> void:
	if player == null and current_scene != null: # quando trocar de cena
		player = current_scene.get_node("MainPlayer")
	
	# Mantém HUD sincronizado com variáveis globais
	update_hud_labels()

func update_hud_labels() -> void:
	if life_label:
		life_label.text = "Vidas: " + str(GlobalVars.get_player_lives())
	if attempts_label:
		attempts_label.text = "Tentativas: " + str(GlobalVars.get_player_attempts())

func go_to_scene(path :String):
	print("Going to Scene:" + path)
	current_scene.free()
	var res := ResourceLoader.load(path)
	current_scene = res.instantiate()
	player = null
	add_child(current_scene)
