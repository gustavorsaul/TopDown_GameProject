extends Node2D

@onready var player := $MainPlayer
var current_scene : Node2D = null

func _ready() -> void:
	get_tree().call_group("MainPlayer", "print_position")
	current_scene = get_child(1)
	if current_scene != null:
		player = current_scene.get_node_or_null("MainPlayer")
		print("Tutorial carregado automaticamente: ", current_scene.name)
	
func _physics_process(delta: float) -> void:
	if player == null and current_scene != null: # quando trocar de cena
		player = current_scene.get_node("MainPlayer")

func go_to_scene(path :String):
	print("Going to Scene:" + path)
	current_scene.free()
	var res := ResourceLoader.load(path)
	current_scene = res.instantiate()
	player = null
	add_child(current_scene)
