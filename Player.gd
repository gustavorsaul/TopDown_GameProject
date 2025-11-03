extends CharacterBody2D

@export var speed = 300.0

@onready var sprite = $AnimatedSprite2D
@onready var life_bar = $LifeBar


@export var arrow : PackedScene

@onready var tiros = 0

# Vida gerenciada pelo GlobalVars

@export var dash_duration = 0.1
@export var dash_speed = 1000.0
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_start_position = Vector2.ZERO
@onready var dash_timer: Timer

# Sistema de invencibilidade para evitar dano múltiplo
var is_invincible = false
@export var invincibility_duration = 1  # duração da invencibilidade em segundos

# Sistema de trail simples para dash
var dash_trails = []
@export var trail_count = 3  # número de rastros

func _ready():
	# Adiciona o player ao grupo "player" para detecção pelas traps
	add_to_group("player")
	# Configura o timer do dash
	dash_timer = Timer.new()
	dash_timer.one_shot = true
	dash_timer.wait_time = dash_duration
	add_child(dash_timer)
	dash_timer.timeout.connect(stop_dashing)
	
	# Atualiza a barra de vida com o valor atual do GlobalVars
	_update_life_label()

func get_8way_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	# Verificar se shift foi pressionado para dash
	if Input.is_action_just_pressed("shift") and input_direction != Vector2.ZERO and GlobalVars.dash_number > 0:
		GlobalVars.dash_number -= 1
		start_dash(input_direction)
	
	# Se não estiver fazendo dash, movimento normal
	if not is_dashing:
		velocity = input_direction * speed
	
func animate():
	
	if velocity.x > 0:
		sprite.play("right")
	elif velocity.x < 0:
		sprite.play("left")
	elif velocity.y > 0:
		sprite.play("down")
	elif velocity.y < 0:
		sprite.play("up")
	else:
		sprite.stop()
		
func start_dash(direction: Vector2):
	if not is_dashing:
		is_dashing = true
		dash_direction = direction
		dash_start_position = position
		velocity = dash_direction * dash_speed
		print("Dash!")
		# Inicia o timer para encerrar o dash
		dash_timer.stop()
		dash_timer.wait_time = dash_duration
		dash_timer.start()

func update_dash(delta):
	if is_dashing:
		# Usar velocity para respeitar colisões
		velocity = dash_direction * dash_speed
		
		# Criar rastro visual durante o dash
		_create_dash_trail()
		

func move_8way(delta):
	get_8way_input()
	update_dash(delta)
	animate()
	
	# Mover e verificar colisões
	move_and_slide()
	

func _physics_process(delta):
	move_8way(delta)
	
	if (Input.is_action_just_pressed("mouseLeft")):
		tiros += 1
		print("Tiro ", tiros)
		var b := arrow.instantiate()
		b.position = position
		b.setup_arrow(get_global_mouse_position())
		owner.add_child(b)

func stop_dashing() -> void:
	is_dashing = false
	velocity = Vector2.ZERO

func take_damage(amount: int) -> void:
	
	# Verifica se o player está invencível
	if is_invincible:
		print("Player está invencível, dano ignorado!")
		return
	
	# Aplica o dano usando o GlobalVars
	GlobalVars.reduce_player_life(amount)
	_update_life_label()
	_start_invincibility()
	print("Verificando vida")

	print("Vidas:", GlobalVars.player_lives)
	print("Tentativas:", GlobalVars.player_attempts)

	if GlobalVars.get_player_lives() <= 0:
		print("morreu")
		die()  # animação, etc.
		GlobalVars.handle_attempt_reset()

		
signal player_died(respawn_path: String)

func die() -> void:
	print("Player morreu! Iniciando respawn...")

	# Limpa efeitos visuais
	_clear_all_trails()
	
	# Obtém o caminho da cena de respawn
	var respawn_scene = GlobalVars.get_respawn_scene()
	print("Emitindo sinal para respawn na cena:", respawn_scene)

	# Em vez de trocar a cena diretamente:
	emit_signal("player_died", respawn_scene)

func _clear_all_trails() -> void:
	# Remove todos os rastros ativos
	for trail in dash_trails:
		if is_instance_valid(trail):
			trail.queue_free()
	dash_trails.clear()

func _update_life_label() -> void:
	if is_instance_valid(life_bar):
		life_bar.value = GlobalVars.get_player_lives()

func _start_invincibility() -> void:
	is_invincible = true
	print("Invencibilidade ativada por ", invincibility_duration, " segundos")
	
	# Timer para remover a invencibilidade
	get_tree().create_timer(invincibility_duration).timeout.connect(_end_invincibility)

func _end_invincibility() -> void:
	is_invincible = false
	print("Invencibilidade desativada")

func _create_dash_trail() -> void:
	# Criar um sprite simples de rastro
	var trail_sprite = Sprite2D.new()
	trail_sprite.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	trail_sprite.position = position
	trail_sprite.scale = sprite.scale * 0.9  # Quase do tamanho original
	trail_sprite.modulate = Color.WHITE
	trail_sprite.modulate.a = 0.6  # Menos transparente
	
	# Adicionar ao mundo
	get_parent().add_child(trail_sprite)
	
	# Adicionar à lista
	dash_trails.append(trail_sprite)
	
	# Limitar número de rastros
	if dash_trails.size() > trail_count:
		var old_trail = dash_trails.pop_front()
		if is_instance_valid(old_trail):
			old_trail.queue_free()
	
	# Remover após um tempo mais rápido
	get_tree().create_timer(0.15).timeout.connect(func(): 
		if is_instance_valid(trail_sprite):
			trail_sprite.queue_free()
		dash_trails.erase(trail_sprite)
	)
	
	
