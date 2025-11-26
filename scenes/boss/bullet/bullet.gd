extends Area2D

@export var speed: float = 250.0
@export var damage: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Destroy bullet automatically after 5 seconds to save performance
	get_tree().create_timer(5.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	# Move forward based on rotation
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Check if the body HAS the function we want to call (safer than checking names)
	if body.has_method("hit_by_ghost"):
		body.hit_by_ghost()
		queue_free()
		return # Stop here so we don't delete twice

	# Check for walls (TileMaps or specific Wall objects)
	# This checks if it's a TileMap OR if it's in a group called "walls"
	if body is TileMapLayer or body is TileMap or body.is_in_group("walls"):
		queue_free()
