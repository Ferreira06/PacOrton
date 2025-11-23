extends CharacterBody2D

# CRITICAL: Set this to (16, 16) in the Inspector.
@export var tile_size: Vector2 = Vector2(16, 16)
@export var speed: int = 110

@onready var pacman_animation: AnimatedSprite2D = $PacmanAnimation

var current_dir: Vector2 = Vector2.ZERO
var queued_dir: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO

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

# REPLACED: Using Physics Server test_move instead of RayCast
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

	## 1. Determine how far we want to check (one grid step)
	#var step = direction * get_step_size(direction)
	#
	## 2. Use the physics engine to test a virtual movement.
	## global_transform: The player's current position and rotation.
	## step: The vector we want to travel.
	## test_move returns TRUE if a collision WOULD happen.
	#var would_collide = test_move(global_transform, step)
	#
	## If we WOULD collide, we CANNOT move.
	#return not would_collide
