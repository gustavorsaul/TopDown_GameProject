extends Node2D
signal level_finished(next_scene_path: String)

@onready var lever := get_node_or_null("Lever")
@onready var return_home := get_node_or_null("ReturnHome")

@onready var door := $WoodDoor

@onready var sign_arrow := $MainPlayer/Camera2D/Sprite2D

func _ready():
	
	if door:
		door.open_door()
		door.close_door()
	
	if lever:
		lever.connect("lever_activated", Callable(self, "_on_lever_activated"))
	if return_home:
		return_home.connect("body_entered", Callable(self, "_on_return_home_entered"))
		return_home.set_deferred("monitoring", false)

func _on_lever_activated(room_id: String):
	# print("Alavanca da", room_id, "ativada → liberando retorno.")
	door.open_door()
	if return_home:
		return_home.set_deferred("monitoring", true)
	
	if sign_arrow:
		sign_arrow.visible = true
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = false
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = true
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = false
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = true
		await get_tree().create_timer(0.5).timeout
		sign_arrow.visible = false

func _on_return_home_entered(body: Node) -> void:
	if body.name == "MainPlayer":
		GlobalVars.complete_room_part2(1)
		
		# Define o respawn do player ao voltar para Home
		GlobalVars.set_next_respawn(Vector2(-285, 285))  
		
		# print("Player voltou para a entrada → emitindo sinal para Home")
		emit_signal("level_finished", "res://02_home/Home.tscn")
