extends CharacterBody2D

@export var arrow_scene: PackedScene = preload("res://04_room_n2/Flecha.tscn")
@export var shoot_interval: float = 1.0
@export var vision_range: float = 1000.0  # Alcance máximo de visão do arqueiro

@onready var sprite = $AnimatedSprite2D
@onready var life_bar = $LifeBar
@onready var ray_cast = $RayCast2D  # Adicione um RayCast2D como filho do arqueiro na cena

var life: int = 3
var shoot_timer: Timer
var can_shoot: bool = true
var is_shooting: bool = false
var player = null  # Referência ao player

signal archer_died

func _ready() -> void:
	# Configurar barra de vida
	life_bar.max_value = life
	life_bar.value = life
	
	add_to_group("archers")
	
	# Configurar animação inicial
	sprite.play("right")
	
	# Timer de disparo automático
	shoot_timer = Timer.new()
	shoot_timer.one_shot = false
	shoot_timer.autostart = true
	shoot_timer.wait_time = shoot_interval
	add_child(shoot_timer)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	# Conectar sinal de animação finalizada
	sprite.animation_finished.connect(_on_animation_finished)
	
	# Configurar RayCast2D se não existir
	if not ray_cast:
		ray_cast = RayCast2D.new()
		add_child(ray_cast)
	
	# Configurar o raycast para detectar paredes e o player
	ray_cast.enabled = true
	ray_cast.collision_mask = 1  # Layer de colisão das paredes
	ray_cast.collide_with_areas = false
	ray_cast.collide_with_bodies = true
	
	# Encontrar o player na cena
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("ERRO: Player não encontrado! Certifique-se de que o player está na cena e no grupo 'player'")

func _process(delta: float) -> void:
	# Verificar se o player está na cena
	if player and not is_shooting:
		# Atualizar a direção do raycast para apontar para o player
		var direction_to_player = (player.global_position - global_position).normalized()
		ray_cast.target_position = direction_to_player * vision_range
		
		# Verificar se o player está dentro do alcance e visível
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= vision_range:
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding():
				var collider = ray_cast.get_collider()
				if collider == player:
					# Player está visível, virar para a direção dele
					if direction_to_player.x > 0:
						if not sprite.animation.begins_with("right") and not is_shooting:
							sprite.play("right")
					else:
						if not sprite.animation.begins_with("left") and not is_shooting:
							sprite.play("left")

func _on_animation_finished() -> void:
	if sprite.animation.ends_with("shooting"):
		# Voltar para a animação padrão
		if sprite.animation == "right_shooting":
			sprite.play("right")
		else:
			sprite.play("left")
		is_shooting = false

func _on_shoot_timer_timeout() -> void:
	if can_shoot and not is_shooting and player:
		# Verificar se o player está no alcance e visível
		var direction_to_player = (player.global_position - global_position).normalized()
		ray_cast.target_position = direction_to_player * vision_range
		ray_cast.force_raycast_update()
		
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= vision_range and ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			if collider == player:
				is_shooting = true
				
				# Virar para a direção do player
				if direction_to_player.x > 0:
					sprite.play("right_shooting")
				else:
					sprite.play("left_shooting")
				
				# Esperar um pouco para disparar a flecha
				await get_tree().create_timer(0.3).timeout
				_shoot_arrow(direction_to_player)

func _shoot_arrow(direction = null) -> void:
	if not arrow_scene:
		print("ERRO: Cena da flecha não configurada!")
		return
	
	# Criar a flecha
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)
	
	# Ajuste de posição para alinhar com o arco
	var offset = Vector2(15, -20) if sprite.animation.begins_with("right") else Vector2(-15, -20)
	arrow.global_position = global_position + offset
	
	# Definir o arqueiro como pai da flecha para evitar colisão
	arrow.archer_parent = self
	
	# Definir a direção da flecha
	if direction:
		# Usar a direção fornecida (direção ao player)
		arrow.set_direction(direction)
		# Opcional: ajustar rotação da flecha para mirar visualmente
		arrow.rotation = direction.angle()
	else:
		# Fallback para o comportamento anterior
		if sprite.animation.begins_with("right"):
			arrow.set_direction(Vector2.RIGHT)
		else:
			arrow.set_direction(Vector2.LEFT)

func take_damage(amount: int) -> void:
	life = max(0, life - amount)
	
	# Atualizar barra de vida
	life_bar.value = life
	
	if life <= 0:
		die()

func die() -> void:
	print("Archer morreu!")
	emit_signal("archer_died")  # sinal para a Room N2
	queue_free()
