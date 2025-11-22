extends CharacterBody2D

@export var speed = 150.0
@export var movement_direction := Vector2.ZERO

@onready var _pacman_animation: AnimatedSprite2D = $PacmanAnimation


func get_input():
	
	if Input.is_action_pressed("ui_left"):
		movement_direction = Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		movement_direction = Vector2(1, 0)
	if Input.is_action_pressed("ui_up"):
		movement_direction = Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		movement_direction = Vector2(0, 1)
	
	velocity = movement_direction * speed

func _physics_process(_delta):
	_pacman_animation.play("normal")
	get_input()
	move_and_slide()
