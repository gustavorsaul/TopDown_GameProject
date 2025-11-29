extends Control

func _ready() -> void:
	GlobalVars.reset_game_completely()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://00_main/Main.tscn")
