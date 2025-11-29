extends Node2D

signal level_finished(next_scene_path: String)

var archers_alive := 0
@onready var door := $WoodDoor

func _ready():
	if door:
		door.close_door()

	var home = get_node_or_null("Area2D")
	if home:
		if not home.is_connected("body_entered", Callable(self, "_on_home_body_entered")):
			home.connect("body_entered", Callable(self, "_on_home_body_entered"))

	call_deferred("refresh_archers")

func refresh_archers() -> void:
	archers_alive = 0
	var archers = get_tree().get_nodes_in_group("tutorial_archers")

	for a in archers:
		if is_instance_valid(a) and not a.is_queued_for_deletion():
			archers_alive += 1
			if not a.is_connected("archer_died", Callable(self, "_on_archer_died")):
				a.connect("archer_died", Callable(self, "_on_archer_died"))
	
	# print("Inimigos vivos no inicio: %d" % archers_alive)

	if archers_alive == 0:
		_open_door_now()

func _on_archer_died() -> void:
	archers_alive = max(0, archers_alive - 1)
	# print("Tutorial: Archer derrotado! Restam: %d" % archers_alive)

	if archers_alive == 0:
		_open_door_now()

func _open_door_now() -> void:
	if door:
		door.open_door()
		# print("Porta do tutorial liberada.")

func _on_home_body_entered(body: Node) -> void:
	if body.name != "MainPlayer":
		return

	if archers_alive > 0:
		# print("Ainda há arqueiros vivos. A porta não deveria estar aberta ou você pulou a parede!")
		return

	if GlobalVars:
		GlobalVars.complete_tutorial()
	
	emit_signal("level_finished", "res://02_home/Home.tscn")
