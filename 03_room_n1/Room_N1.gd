extends Node2D
signal level_finished(next_scene_path: String)

@onready var lever := get_node_or_null("Lever")
@onready var return_home := get_node_or_null("ReturnHome")

func _ready():
	if lever:
		lever.connect("lever_activated", Callable(self, "_on_lever_activated"))
	if return_home:
		return_home.connect("body_entered", Callable(self, "_on_return_home_entered"))
		return_home.set_deferred("monitoring", false)

func _on_lever_activated(room_id: String):
	print("Alavanca da", room_id, "ativada → liberando retorno.")
	if return_home:
		return_home.set_deferred("monitoring", true)

func _on_return_home_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		GlobalVars.complete_room_part2(1)
		
		# Define o respawn do player ao voltar para Home
		GlobalVars.set_next_respawn(Vector2(-285, 285))  
		
		print("Player voltou para a entrada → emitindo sinal para Home")
		emit_signal("level_finished", "res://02_home/Home.tscn")
