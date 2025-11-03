extends Control

func _on_playagain_pressed() -> void:
	get_tree().change_scene_to_file("res://00_main/MainMenu.tscn")
