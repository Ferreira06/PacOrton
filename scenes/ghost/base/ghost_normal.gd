extends CharacterBody2D

const movement_speed = 3000

@export var Goal: Node2D = null


func _ready() -> void:
	$NavigationAgent2D.target_position = Goal.global_position
	

func _physics_process(delta: float) -> void:
	var nav_point_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	print(nav_point_direction)
	velocity = nav_point_direction * movement_speed * delta
	move_and_slide()


func _on_timer_timeout() -> void:
	if $NavigationAgent2D.target_position != Goal.global_position:
		$NavigationAgent2D.target_position = Goal.global_position
	$Timer.start()
