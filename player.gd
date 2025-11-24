extends CharacterBody2D

# CRITICAL: Set this to (16, 16) in the Inspector.
@export var tile_size: Vector2 = Vector2(16, 16)
@export var speed: int = 110

@onready var pacman_animation: AnimatedSprite2D = $PacmanAnimation

var current_dir: Vector2 = Vector2.ZERO
var queued_dir: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var is_powered_up: bool = false
var xp: int = 0

# We no longer need the RayCast2D node. You can delete it from the scene.

func _ready() -> void:
	# Snap to grid to ensure we start clean.
	position = position.snapped(tile_size) + tile_size/2.0
	target_pos = position

func _physics_process(delta: float) -> void:
	handle_input()
	move_player(delta)

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
	print("Current XP: ", xp)
