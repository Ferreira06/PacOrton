extends CharacterBody2D

@export var movement_speed = 80
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
	for goal in ScatterGoalList:
		goal.global_position = goal.global_position.snapped(tile_size)

	actual_state = GhostStates.SCATTERING
	$ScatterTimer.start()
	

func _physics_process(_delta: float) -> void:
	match actual_state:
		GhostStates.SCATTERING : scatter()
		GhostStates.CHASING    : chase()
	
	move_and_slide()


func chase() -> void:
	$NavigationAgent2D.target_position = Player.global_position
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
	$ScatterTimer.stop()
	$ChaseTimer.start()


func _on_chase_timer_timeout() -> void:
	actual_state = GhostStates.SCATTERING
	$ChaseTimer.stop()
	$ScatterTimer.start()
