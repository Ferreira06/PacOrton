extends CharacterBody2D

@export var movement_speed = 80
@export var health: int = 2  # The ghost takes 2 hits to die (or set to 1)

# Movement Variables
@export var increment: Vector2 = Vector2(0, 0)
@export var scatter_time: int
@export var chase_time: int
const tile_size := Vector2(16, 16)

enum GhostStates {
	SCATTERING,
	FRIGHTENED,
	CHASING
}

@export var ScatterGoalList: Array[Marker2D]
@export var Player: CharacterBody2D
@export var actual_state: GhostStates
var nav_point_direction: Vector2
var scatter_goal_index: int = 0

func _ready() -> void:
	# Setup initial movement targets
	if ScatterGoalList.size() > 0:
		for goal in ScatterGoalList:
			goal.global_position = goal.global_position.snapped(tile_size) + increment

	actual_state = GhostStates.SCATTERING
	$ScatterTimer.start()

func _physics_process(_delta: float) -> void:
	match actual_state:
		GhostStates.SCATTERING : scatter()
		GhostStates.CHASING    : chase()
	
	# Move the ghost
	move_and_slide()
	
	# --- NEW: Check if we touched the Player ---
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# If we hit the player, try to damage them
		if collider.has_method("hit_by_ghost"):
			collider.hit_by_ghost()

func chase() -> void:
	$NavigationAgent2D.target_position = Player.global_position + increment 
	nav_point_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	velocity = nav_point_direction * movement_speed


func scatter() -> void:
	$NavigationAgent2D.target_position = ScatterGoalList[scatter_goal_index].global_position
	nav_point_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	velocity = nav_point_direction * movement_speed

	if $NavigationAgent2D.is_target_reached():
		scatter_goal_index = (scatter_goal_index + 1) % ScatterGoalList.size()


func _on_scatter_timer_timeout() -> void:
	actual_state = GhostStates.CHASING
	#print("Cecília")
	$ChaseTimer.start(chase_time)


func _on_chase_timer_timeout() -> void:
	actual_state = GhostStates.SCATTERING
	#print("Gustavo")
	$ScatterTimer.start(scatter_time)

# --- NEW: Function called by the Bullet ---
func take_damage(amount: int) -> void:
	health -= amount
	
	# Optional: Add a flash effect or sound here
	modulate = Color(10, 10, 10) # Flash white
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)    # Return to normal
	
	if health <= 0:
		die()

func die() -> void:
	# Removes ghost from the scene (and the 'ghosts' group)
	# This will automatically update the Tunnel count!
	queue_free()
