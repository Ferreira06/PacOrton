extends CharacterBody2D

# CRITICAL: Set this to (16, 16) in the Inspector.
@export var tile_size: Vector2 = Vector2(16, 16)
@export var speed: int = 110

@export var bullet_scene: PackedScene 
@export var level_up_scene: PackedScene 

@export var sprite_gun: Texture2D
@export var sprite_speed: Texture2D
@onready var gun_decoration: AnimatedSprite2D = $GunDecoration
@onready var speed_decoration: AnimatedSprite2D = $SpeedDecoration

@onready var pacman_animation: AnimatedSprite2D = $PacmanAnimation

var current_dir: Vector2 = Vector2.ZERO
var queued_dir: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var is_powered_up: bool = false
var xp: int = 0
var level: int = 1

var has_gun: bool = false
var has_speed_boost: bool = false
var can_active_boost: bool = true

func _ready() -> void:
	# Snap to grid to ensure we start clean.
	position = position.snapped(tile_size) + tile_size/2.0
	target_pos = position

func _physics_process(delta: float) -> void:
	handle_input()
	
	# Lógica do Boost Ativo (Tecla SPACE)
	if has_speed_boost and Input.is_action_just_pressed("dash") and can_active_boost:
		activate_speed_boost()
		
	# Lógica do Tiro (Tecla Z ou Clique)
	if has_gun and Input.is_action_just_pressed("shoot"): # Configure "ui_accept" ou crie "shoot"
		shoot()
		
	move_player(delta)
	if has_gun:
		gun_decoration.flip_h = pacman_animation.flip_h
		gun_decoration.flip_v = pacman_animation.flip_v
		# Opcional: Se o acessório tiver animação de andar, toque ela também
		if current_dir != Vector2.ZERO:
			gun_decoration.play("walk") # Certifique-se que existe essa animação
		else:
			gun_decoration.play("idle")

	if has_speed_boost:
		speed_decoration.flip_h = pacman_animation.flip_h
		speed_decoration.flip_v = pacman_animation.flip_v

func handle_input() -> void:
	if Input.is_action_pressed("ui_right"):
		pacman_animation.play("normal-right")
		pacman_animation.flip_h = false
		queued_dir = Vector2.RIGHT
		
	elif Input.is_action_pressed("ui_left"):
		pacman_animation.play("normal-right")
		pacman_animation.flip_h = true
		queued_dir = Vector2.LEFT
		
	elif Input.is_action_pressed("ui_up"):
		pacman_animation.play("normal-up")
		pacman_animation.flip_v = false
		queued_dir = Vector2.UP
		
	elif Input.is_action_pressed("ui_down"):
		pacman_animation.play("normal-up")
		pacman_animation.flip_v = true
		queued_dir = Vector2.DOWN

func move_player(delta: float) -> void:
	# 1. Check if we have arrived at the target tile center
	if current_dir == Vector2.ZERO or position.distance_to(target_pos) < 1.5:
		position = target_pos
		
		# 2. Try to turn (Queued Direction)
		if queued_dir != Vector2.ZERO and can_move(queued_dir):
			current_dir = queued_dir
			target_pos = position + (current_dir * get_step_size(current_dir))
		
		# 3. If we can't turn, try to keep going Straight
		elif current_dir != Vector2.ZERO and can_move(current_dir):
			target_pos = position + (current_dir * get_step_size(current_dir))
		
		# 4. Stop if blocked
		else:
			current_dir = Vector2.ZERO

	# 5. Move execution
	if current_dir != Vector2.ZERO:
		position = position.move_toward(target_pos, speed * delta)

func get_step_size(dir: Vector2) -> float:
	if dir.x != 0:
		return tile_size.x
	else:
		return tile_size.y

func can_move(direction: Vector2) -> bool:
	if direction == Vector2.UP and not $up.is_colliding():
		return true
	if direction == Vector2.LEFT and not $left.is_colliding():
		return true
	if direction == Vector2.RIGHT and not $right.is_colliding():
		return true
	if direction == Vector2.DOWN and not $down.is_colliding():
		return true
	return false

func activate_power_up(duration: float):
	is_powered_up = true
	# Change appearance (Visual feedback)
	modulate = Color(1, 1, 0.5) # Turn yellowish/bright
	
	# Wait for the duration, then turn it off
	await get_tree().create_timer(duration).timeout
	
	is_powered_up = false
	modulate = Color(1, 1, 1) # Reset color

func hit_by_ghost():
	if is_powered_up:
		return
	else:
		die()

func die():
	print("Pacman died!")
	get_tree().reload_current_scene()
	
func gain_xp(amount: int):
	xp += amount
	print("XP: ", xp)
	print("Lvl: ", level)	
	if xp >= 10 and level == 1:
		trigger_level_up()

func trigger_level_up():
	level += 1
	# Instancia a tela de Level Up
	if level_up_scene:
		var menu = level_up_scene.instantiate()
		get_tree().root.add_child(menu) # Adiciona na raiz para ficar sobre tudo
		menu.show_cards()
		menu.upgrade_selected.connect(_apply_upgrade)

func _apply_upgrade(power_id: int):
	match power_id:
		1: # ARMA
			has_gun = true
			gun_decoration.visible = true # MOSTRA A ARMA
			print("Poder: Arma Adquirido!")
		2: # VELOCIDADE
			has_speed_boost = true
			speed = 140 
			speed_decoration.visible = true # MOSTRA O ACESSÓRIO DE VELOCIDADE
			print("Poder: Velocidade Adquirida!")
			
			
func shoot():
	if not bullet_scene: return
	
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	# Define a direção do tiro baseada na última direção do player
	var shoot_dir = current_dir if current_dir != Vector2.ZERO else Vector2.RIGHT
	bullet.direction = shoot_dir
	bullet.rotation = shoot_dir.angle() # Gira o sprite da bala
	get_parent().add_child(bullet)

func activate_speed_boost():
	can_active_boost = false
	var old_speed = speed
	speed = 250 # Velocidade insana por 2 segundos
	
	# Cria um timer temporário
	await get_tree().create_timer(2.0).timeout
	
	speed = old_speed # Volta ao normal (que já é o buffado passivo)
	
	# Cooldown de 5 segundos para usar de novo
	await get_tree().create_timer(5.0).timeout
	can_active_boost = true
