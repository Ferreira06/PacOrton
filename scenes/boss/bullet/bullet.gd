extends Area2D
class_name Bullet

@export var speed = 2000
var sprite_type

@export var target: Vector2

func _process(delta):
	$AnimatedSprite2D.look_at(target)
	var direction = (target - global_position).normalized()
	global_position += direction * speed * delta
	if global_position.distance_to(target) < 5:
		queue_free()
