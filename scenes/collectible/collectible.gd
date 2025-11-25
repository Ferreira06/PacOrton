extends Area2D

enum Type { POINT, STAR }
@export var item_type: Type = Type.POINT

@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	# Simply play the animation matching the type
	if item_type == Type.POINT:
		sprite.play("point")
	elif item_type == Type.STAR:
		sprite.play("star")

func _on_body_entered(body: Node2D) -> void:
	# Safety check to ensure only Player collects it
	if body.name == "Player" or body.is_in_group("Player"):
		collect(body)
		

func collect(player):
	match item_type:
		Type.POINT:
			player.gain_xp(1)
		Type.STAR:
			player.activate_power_up(10.0)
			
	queue_free()
