extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# Conecte o sinal "area_entered" ou "body_entered" do Bullet nele mesmo
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1) # Dá 1 de dano
		queue_free() # Bala some
	elif body.name != "Player": # Se bater na parede
		queue_free()
