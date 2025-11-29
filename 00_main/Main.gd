extends Node2D

@onready var player := $Tutorial/MainPlayer
var current_scene : Node2D = null

@onready var bar_hp := $HUD/HP_Count/TextureRect/TextureProgressBar

@onready var bar_lives := $HUD/Lives_Count/TextureRect/TextureProgressBar

@onready var bar_dash := $HUD/Dash_Count/TextureRect/TextureProgressBar

@onready var heart1 := $HUD/Lives_Count/Heart1
@onready var heart2 := $HUD/Lives_Count/Heart2
@onready var heart3 := $HUD/Lives_Count/Heart3

func _ready() -> void:
	
	if bar_dash:
		bar_dash.max_value = 2
		bar_dash.value = 2 
	
	if bar_lives:
		bar_lives.max_value = 3 
		bar_lives.value = 3
		
	if bar_hp:
		bar_hp.max_value = 3 
	
	current_scene = get_node_or_null("Tutorial")
	if current_scene:
		player = current_scene.get_node_or_null("MainPlayer")
		# print("Tutorial carregado automaticamente:", current_scene.name)
		_connect_scene_signals()

	update_hud_visuals()
	
	await get_tree().process_frame
	await Transition.fade_in()

func _physics_process(delta: float) -> void:
	if player == null and current_scene != null:
		player = current_scene.get_node_or_null("MainPlayer")
		if player:
			_connect_player_signal()

	update_hud_visuals()
	
	
func update_hud_visuals() -> void:

	if bar_dash:
		var dashes_atuais = float(GlobalVars.dash_number)
		
		var progresso_recarga = GlobalVars.get_dash_recharge_progress()
		
		bar_dash.value = dashes_atuais + progresso_recarga
		
	if bar_lives:
		bar_lives.value = GlobalVars.get_remaining_attempts_for_hud()
	
	if bar_hp:
		bar_hp.value = GlobalVars.get_player_lives()

	if GlobalVars.player_attempts == 1:
		heart1.visible = true
		heart2.visible = true
		heart3.visible = true
		
	if GlobalVars.player_attempts == 2:
		heart1.visible = true
		heart2.visible = true
		heart3.visible = false
	
	if GlobalVars.player_attempts == 3:
		heart1.visible = true
		heart2.visible = false
		heart3.visible = false
	
	if GlobalVars.player_attempts == 4:
		heart1.visible = false
		heart2.visible = false
		heart3.visible = false

func _connect_scene_signals() -> void:
	if current_scene and current_scene.has_signal("level_finished"):
		if not current_scene.is_connected("level_finished", Callable(self, "_on_level_finished")):
			current_scene.connect("level_finished", Callable(self, "_on_level_finished"))
	_connect_player_signal()

func _connect_player_signal() -> void:
	if player and player.has_signal("player_died"):
		if not player.is_connected("player_died", Callable(self, "_on_player_died")):
			player.connect("player_died", Callable(self, "_on_player_died"))

func go_to_scene(path : String):
	await Transition.fade_out()
	
	if current_scene:
		current_scene.queue_free()

	var res := ResourceLoader.load(path)
	current_scene = res.instantiate()
	add_child(current_scene)

	player = current_scene.get_node_or_null("MainPlayer")
	_connect_scene_signals()
	
	await Transition.fade_in()

func _on_level_finished(next_scene_path: String):
	go_to_scene(next_scene_path)

func _on_player_died(respawn_path: String):
	go_to_scene(respawn_path)
