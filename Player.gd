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

@export var shoot_cooldown = 0.5
var can_shoot = true
@onready var shoot_timer: Timer

# Sistema de invencibilidade para evitar dano múltiplo
var is_invincible = false
@export var invincibility_duration = 1  # duração da invencibilidade em segundos

# Sistema de trail simples para dash
var dash_trails = []
@export var trail_count = 3  # número de rastros

signal player_died(respawn_path: String)

func _ready():
	add_to_group("player")
	
	# Configura timer do dash (Duração do movimento)
	dash_timer = Timer.new()
	dash_timer.one_shot = true
	dash_timer.wait_time = dash_duration
	add_child(dash_timer)
	dash_timer.timeout.connect(stop_dashing)
	
	# Configura timer de tiro
	shoot_timer = Timer.new()
	shoot_timer.one_shot = true
	shoot_timer.wait_time = shoot_cooldown
	add_child(shoot_timer)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	# Conecta colisão de flechas
	var area2d = get_node_or_null("Area2D")
	if area2d:
		if not area2d.is_connected("area_entered", Callable(self, "_on_arrow_area_entered")):
			area2d.connect("area_entered", Callable(self, "_on_arrow_area_entered"))
	
	# Atualiza a barra de vida local (se existir)
	await get_tree().process_frame
	_update_life_label()

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func get_8way_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	# --- ALTERAÇÃO PRINCIPAL DO DASH ---
	# Usa a função use_dash() que retorna true se gastou a stamina e iniciou o timer
	if Input.is_action_just_pressed("shift") and input_direction != Vector2.ZERO:
		if GlobalVars.use_dash(): 
			start_dash(input_direction)
	
	# Se não estiver fazendo dash, movimento normal
	if not is_dashing:
		velocity = input_direction * speed
	
func animate():
	if velocity.x > 0:
		sprite.play("right_robe")
	elif velocity.x < 0:
		sprite.play("left_robe")
	elif velocity.y > 0:
		sprite.play("down_robe")
	elif velocity.y < 0:
		sprite.play("up_robe")
	else:
		sprite.stop()
		
func start_dash(direction: Vector2):
	if not is_dashing:
		is_dashing = true
		dash_direction = direction
		dash_start_position = position
		velocity = dash_direction * dash_speed
		
		# Inicia o timer para encerrar o movimento do dash
		dash_timer.stop()
		dash_timer.wait_time = dash_duration
		dash_timer.start()

func update_dash(delta):
	if is_dashing:
		velocity = dash_direction * dash_speed
		_create_dash_trail()

func move_8way(delta):
	get_8way_input()
	update_dash(delta)
	animate()
	move_and_slide()

func _physics_process(delta):
	move_8way(delta)
	
	if Input.is_action_just_pressed("mouseLeft") and can_shoot:
		shoot()

func shoot() -> void:
	can_shoot = false
	shoot_timer.start()
	tiros += 1
	var b := arrow.instantiate()
	b.position = position
	b.setup_arrow(get_global_mouse_position())
	owner.add_child(b)

func stop_dashing() -> void:
	is_dashing = false
	velocity = Vector2.ZERO

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	# Aplica o dano no GlobalVars
	var current_hp = GlobalVars.reduce_player_life(amount)
	
	# Atualiza visual local (barra em cima da cabeça, se tiver)
	_update_life_label()
	
	# Ativa invencibilidade
	_start_invincibility()

	# Verifica Morte
	if current_hp <= 0:
		print("Player morreu (HP <= 0)")
		
		# Primeiro atualiza as stats globais (incrementa tentativa, reseta HP para 3)
		GlobalVars.handle_attempt_reset()
		
		# Depois inicia o processo de troca de cena
		die()

func die() -> void:
	print("Iniciando respawn...")
	
	# 1. Impede que o código de movimento (_physics_process) continue rodando
	set_physics_process(false)
	velocity = Vector2.ZERO # Para o personagem imediatamente se estiver deslizando
	
	_clear_all_trails()
	
	modulate.a = 1.0
	
	# 2. Toca a animação
	sprite.play("death")
	
	# 3. PAUSA: Espera 1.0 segundo (ajuste esse valor conforme a duração da sua animação)
	await get_tree().create_timer(1.0).timeout
	
	# 4. Continua o processo de troca de cena
	var respawn_scene = GlobalVars.get_respawn_scene()
	GlobalVars.next_respawn_position = Vector2.ZERO
	
	# Emite o sinal para o Main.gd trocar a cena
	emit_signal("player_died", respawn_scene)

func _clear_all_trails() -> void:
	for trail in dash_trails:
		if is_instance_valid(trail):
			trail.queue_free()
	dash_trails.clear()

func _update_life_label() -> void:
	if is_instance_valid(life_bar):
		life_bar.value = GlobalVars.get_player_lives()

func _start_invincibility() -> void:
	is_invincible = true
	# Piscar o sprite para indicar dano (Opcional, mas visualmente bom)
	modulate.a = 0.6
	get_tree().create_timer(invincibility_duration).timeout.connect(_end_invincibility)

func _end_invincibility() -> void:
	is_invincible = false
	modulate.a = 1.0 # Volta opacidade ao normal

func _create_dash_trail() -> void:
	var trail_sprite = Sprite2D.new()
	trail_sprite.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	trail_sprite.position = position
	trail_sprite.scale = sprite.scale * 0.9
	trail_sprite.modulate = Color.WHITE
	trail_sprite.modulate.a = 0.6
	
	get_parent().add_child(trail_sprite)
	dash_trails.append(trail_sprite)
	
	if dash_trails.size() > trail_count:
		var old_trail = dash_trails.pop_front()
		if is_instance_valid(old_trail):
			old_trail.queue_free()
	
	get_tree().create_timer(0.15).timeout.connect(func(): 
		if is_instance_valid(trail_sprite):
			trail_sprite.queue_free()
		dash_trails.erase(trail_sprite)
	)

func _on_arrow_area_entered(area: Area2D) -> void:
	if area.name == "Flecha" or area.is_in_group("arrow") or (area.get_script() and area.get_script().resource_path.contains("Flecha")):
		take_damage(1)
		area.queue_free()
