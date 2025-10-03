extends Control

@onready var health_fill = $HealthFill
@onready var health_label = $HealthLabel

var max_health: int = 100
var current_health: int = 100

func _ready():
	update_health_display()

func set_max_health(value: int):
	max_health = value
	current_health = max_health
	if is_instance_valid(health_fill):
		health_fill.max_value = max_health
	update_health_display()

func set_health(value: int):
	current_health = clamp(value, 0, max_health)
	update_health_display()

func update_health_bar(health: int, max_hp: int):
	max_health = max_hp
	current_health = health
	update_health_display()

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	update_health_display()
	
	# Efeito visual quando toma dano
	animate_damage()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	update_health_display()

func update_health_display():
	# Verificar se os nós existem antes de usá-los
	if not is_instance_valid(health_fill) or not is_instance_valid(health_label):
		print("HealthBar: Nós não encontrados!")
		return
	
	# Atualizar barra de progresso
	health_fill.value = current_health
	health_fill.max_value = max_health
	
	# Atualizar label
	health_label.text = str(current_health) + "/" + str(max_health)
	
	# Mudar cor baseada na porcentagem de vida
	var health_percentage = float(current_health) / float(max_health)
	update_health_color(health_percentage)

func update_health_color(percentage: float):
	if not is_instance_valid(health_fill):
		return
		
	var health_fill_style = health_fill.get_theme_stylebox("fill")
	
	if percentage > 0.6:
		# Verde quando vida alta
		health_fill_style.bg_color = Color(0.2, 0.8, 0.2, 1.0)
	elif percentage > 0.3:
		# Amarelo quando vida média
		health_fill_style.bg_color = Color(0.8, 0.8, 0.2, 1.0)
	else:
		# Vermelho quando vida baixa
		health_fill_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)

func animate_damage():
	# Efeito de piscar quando toma dano
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func is_dead() -> bool:
	return current_health <= 0

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)
