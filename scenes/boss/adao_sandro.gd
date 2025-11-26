extends CharacterBody2D

const screen_size = Vector2(1920, 1080)

@onready var bullet_scene = preload("res://scenes/boss/bullet/bullet.tscn")
var timeout = false

var directions: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(screen_size.x / 2, 0),
	Vector2(screen_size.x, 0),
	Vector2(screen_size.x, screen_size.y / 2),
	Vector2(screen_size.x, screen_size.y),
	Vector2(screen_size.x / 2, screen_size.y),
	Vector2(0, screen_size.y),
	Vector2(0, screen_size.y / 2)
]

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		for dir in directions:
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			bullet.target = dir


func _on_timer_timeout() -> void:
	timeout = true
