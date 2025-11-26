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

# Signals
signal health_changed(current_hp)
signal stats_changed(current_xp, max_xp, current_level)
signal powerup_unlocked(id) 
signal powerup_switched(id)

@export var max_health: int = 3
var current_health: int

# --- NEW: Invincibility Flag ---
var can_take_damage: bool = true

var current_selected_powerup: int = 0 # 0=Nenhum, 1=Arma, 2=Velocidade

var has_gun: bool = false
var has_speed_boost: bool = false
var can_active_boost: bool = true

func _ready() -> void:
	current_health = max_health
	# Snap to grid to ensure we start clean.
	position = position.snapped(tile_size) + tile_size/2.0
	target_pos = position

func _physics_process(delta: float) -> void:
	handle_input()
	handle_powerup_switching()
	
	if has_speed_boost and Input.is_action_just_pressed("dash") and can_active_boost:
		if current_selected_powerup == 2:
			activate_speed_boost()
		
	# Shoot Logic
	if has_gun and Input.is_action_just_pressed("shoot"):
		if current_selected_powerup == 1:
			shoot()
		
	move_player(delta)
	

func handle_input() -> void:
	if Input.is_action_pressed("move_right"):
		pacman_animation.play("normal-right")
		pacman_animation.flip_h = false
		queued_dir = Vector2.RIGHT
		
	elif Input.is_action_pressed("move_left"):
		pacman_animation.play("normal-right")
		pacman_animation.flip_h = true
		queued_dir = Vector2.LEFT
		
	elif Input.is_action_pressed("move_up"):
		pacman_animation.play("normal-up")
		pacman_animation.flip_v = false
		queued_dir = Vector2.UP
		
	elif Input.is_action_pressed("move_down"):
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
	modulate = Color(1, 1, 0.5) 
	await get_tree().create_timer(duration).timeout
	is_powered_up = false
	modulate = Color(1, 1, 1) 

func die():
	print("Pacman died!")
	get_tree().reload_current_scene()
	
func hit_by_ghost():
	# If we have a star (power up) OR are currently blinking from damage
	if is_powered_up or not can_take_damage:
		return
	
	# Apply Damage
	current_health -= 1
	health_changed.emit(current_health)
	
	if current_health <= 0:
		die()
	else:
		# --- INVINCIBILITY LOGIC ---
		can_take_damage = false
		print("Damage taken! HP: ", current_health)
		
		# Visual feedback (Blinking red)
		modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		modulate = Color(1, 1, 1)
		await get_tree().create_timer(0.2).timeout
		modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.2).timeout
		modulate = Color(1, 1, 1)
		
		# Cooldown finished
		can_take_damage = true

func gain_xp(amount: int):
	xp += amount
	var xp_next_level = 10 * (level * 2) 
	stats_changed.emit(xp, xp_next_level, level)
	
	if xp >= xp_next_level:
		trigger_level_up()

func trigger_level_up():
	level += 1
	xp = 0
	var xp_next_level = 10 * level
	stats_changed.emit(xp, xp_next_level, level)
	if level_up_scene:
		var menu = level_up_scene.instantiate()
		get_tree().root.add_child(menu)
		
		var my_upgrades = []
		if has_gun: my_upgrades.append(1)
		if has_speed_boost: my_upgrades.append(2)
			
		if my_upgrades.size() < 2 :
			menu.show_cards(my_upgrades)
		
		menu.upgrade_selected.connect(_apply_upgrade)

func handle_powerup_switching():
	if Input.is_key_pressed(KEY_1):
		if has_gun: 
			current_selected_powerup = 1
			speed_decoration.visible = false
			gun_decoration.visible = true
			powerup_switched.emit(1) 
			
	elif Input.is_key_pressed(KEY_2):
		if has_speed_boost: 
			current_selected_powerup = 2
			gun_decoration.visible = false
			speed_decoration.visible = true
			speed = 140 
			powerup_switched.emit(2)

func _apply_upgrade(power_id: int):
	match power_id:
		1: # GUN
			has_gun = true
			speed_decoration.visible = false
			gun_decoration.visible = true
			powerup_unlocked.emit(1)
			current_selected_powerup = 1
			
		2: # SPEED
			has_speed_boost = true
			gun_decoration.visible = false
			speed_decoration.visible = true
			speed = 140 
			powerup_unlocked.emit(2)
			if current_selected_powerup == 0:
				current_selected_powerup = 2
			
func shoot():
	if not bullet_scene: return
	
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	var shoot_dir = current_dir if current_dir != Vector2.ZERO else Vector2.RIGHT
	bullet.direction = shoot_dir
	bullet.rotation = shoot_dir.angle()
	get_parent().add_child(bullet)

func activate_speed_boost():
	can_active_boost = false
	var old_speed = speed
	speed = 250 
	await get_tree().create_timer(2.0).timeout
	speed = old_speed 
	await get_tree().create_timer(5.0).timeout
	can_active_boost = true
