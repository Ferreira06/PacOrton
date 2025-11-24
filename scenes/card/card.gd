extends TextureButton

@onready var anim_sprite = $AnimatedSprite2D

# Variável para controlar o tamanho final do card
var target_scale: Vector2 = Vector2(5,5) 

func set_animation(anim_name: String):
	if anim_sprite:
		anim_sprite.play(anim_name)

func _ready():
	# 1. Define o ponto de pivô no centro para a animação de zoom funcionar bem
	# (Assumindo que sua textura tem cerca de 32x64 pixels)
	pivot_offset = size / 2 
	
	# 2. Começa invisível (escala 0) e cresce até o target_scale
	scale = Vector2(0, 0)
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, 0.5)
	
	# Conectar sinais
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	# Aumenta 10% em relação ao tamanho base
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", target_scale * 1.1, 0.1)

func _on_exit():
	# Volta ao tamanho base
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", target_scale, 0.1)
