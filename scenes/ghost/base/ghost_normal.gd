extends CharacterBody2D

@export var speed = 115
const tile_size = Vector2(16, 16)
var current_dir: Vector2 = Vector2.ZERO
var queued_dir: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var hp: int = 5
var player = Vector2(1280, 720)
@export var player_node: Node2D # Drag your Player object here in the Inspector!

func _ready() -> void:
	position = position.snapped(tile_size) + tile_size/2.0
	target_pos = position


func _physics_process(delta: float) -> void:
	# 1. Update the target to be the REAL player position
	if player_node:
		# We update the 'player' variable your script uses for distance calculation
		player = player_node.position 
	
	# Keep your existing move logic
	move(available_moves(), delta)

func min_dist(available_directions) -> Vector2:
	var min_d = INF
	var min_dir := Vector2.ZERO
	for dir in available_directions:
		var new_pos = position + dir * 16
		var dist = new_pos.distance_to(player)
		if dist < min_d:
			min_dir = dir
			min_d = dist
	return min_dir

func move(available_directions, delta) -> void:
	var min_d = min_dist(available_directions)
	
	current_dir = min_d
	
	if current_dir == Vector2.ZERO or position.distance_to(target_pos) < 1.5:
		position = target_pos
		
		if current_dir != Vector2.ZERO and can_move(current_dir):
			target_pos = position + (current_dir * get_step_size(current_dir))
#
	## 5. Move execution
	if current_dir != Vector2.ZERO:
		position = position.move_toward(target_pos, speed * delta)


func get_step_size(dir: Vector2) -> float:
	if dir.x != 0:
		return tile_size.x
	else:
		return tile_size.y


func available_moves() -> Array[Vector2]:
	var directions := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]
	var available_directions: Array[Vector2] = []
	
	for v2 in directions:
		if can_move(v2) and v2 != -current_dir:
			available_directions.append(v2)
		#else:
	
	return available_directions


func can_move(direction: Vector2) -> bool:
	if direction == Vector2.UP and not $ghost_up.is_colliding():
		return true
	elif direction == Vector2.LEFT and not $ghost_left.is_colliding():
		return true
	elif direction == Vector2.RIGHT and not $ghost_right.is_colliding():
		return true
	elif direction == Vector2.DOWN and not $ghost_down.is_colliding():
		return true
	return false
	
	
func _on_hitbox_body_entered(body: Node):
	# Check if the body we touched is the Player
	if body.name == "Player":
		if body.is_powered_up:
			die()
		else:
			body.hit_by_ghost()

func take_damage(amount: int) -> void:
	hp -= amount
	# Feedback visual (piscar vermelho)
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	
	if hp <= 0:
		die()
func die():
	print("Ghost eaten!")
	queue_free() # Remove ghost
	# Or send it back to the cage: position = Vector2(x, y)
